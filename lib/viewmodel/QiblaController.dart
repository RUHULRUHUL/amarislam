import 'dart:async';
import 'dart:math';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:adhan/adhan.dart';

class QiblaController extends GetxController {
  final Rx<double?> direction = Rxn<double>();
  final Rx<Position?> currentPosition = Rxn<Position>();
  final RxDouble qiblaAngle = 0.0.obs;
  final RxDouble distanceToKaaba = 0.0.obs;
  final RxString locationError = ''.obs;
  final RxBool isLoading = true.obs;

  StreamSubscription? _compassSubscription;

  @override
  void onInit() {
    super.onInit();
    checkPermissionsAndFetchLocation();
  }

  Future<void> checkPermissionsAndFetchLocation() async {
    isLoading.value = true;
    try {
      var permission = await Permission.location.status;
      if (permission.isDenied) {
        permission = await Permission.location.request();
      }

      if (permission.isGranted) {
        Position position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high);
        currentPosition.value = position;
        calculateQibla(position.latitude, position.longitude);
        startCompass();
      } else {
        locationError.value = "Location permission is required for Qibla direction.";
      }
    } catch (e) {
      locationError.value = "Error fetching location: $e";
    } finally {
      isLoading.value = false;
    }
  }

  void calculateQibla(double lat, double lng) {
    final coordinates = Coordinates(lat, lng);
    final qibla = Qibla(coordinates);
    qiblaAngle.value = qibla.direction;

    // Distance to Kaaba (Mecca coordinates: 21.4225, 39.8262)
    double distanceInMeters = Geolocator.distanceBetween(
      lat,
      lng,
      21.4225,
      39.8262,
    );
    distanceToKaaba.value = distanceInMeters / 1000; // In KM
  }

  void startCompass() {
    _compassSubscription = FlutterCompass.events?.listen((event) {
      direction.value = event.heading;
    });
  }

  @override
  void onClose() {
    _compassSubscription?.cancel();
    super.onClose();
  }
}
