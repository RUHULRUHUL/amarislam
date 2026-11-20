import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TasbihController extends GetxController {
  final RxInt count = 0.obs;
  final RxInt lapCount = 0.obs;
  final RxInt targetCount = 33.obs;
  
  @override
  void onInit() {
    super.onInit();
    loadCount();
  }

  void increment() {
    count.value++;
    HapticFeedback.mediumImpact();
    
    if (count.value >= targetCount.value) {
      lapCount.value++;
      count.value = 0;
      HapticFeedback.heavyImpact();
    }
    saveCount();
  }

  void reset() {
    count.value = 0;
    lapCount.value = 0;
    saveCount();
    HapticFeedback.vibrate();
  }

  void setTarget(int value) {
    targetCount.value = value;
    count.value = 0;
    saveCount();
  }

  Future<void> saveCount() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('tasbih_count', count.value);
    await prefs.setInt('tasbih_lap', lapCount.value);
    await prefs.setInt('tasbih_target', targetCount.value);
  }

  Future<void> loadCount() async {
    final prefs = await SharedPreferences.getInstance();
    count.value = prefs.getInt('tasbih_count') ?? 0;
    lapCount.value = prefs.getInt('tasbih_lap') ?? 0;
    targetCount.value = prefs.getInt('tasbih_target') ?? 33;
  }
}
