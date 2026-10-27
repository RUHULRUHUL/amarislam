import 'package:amarislam/view/BottomNavScreen.dart';
import 'package:amarislam/view/SettingsScreen.dart';
import 'package:amarislam/view/onboard/onboardscreen.dart';
import 'package:amarislam/view/profile/EnterNameScreen.dart';
import 'package:amarislam/view/profile/ProfileScreen.dart';
import 'package:get/get.dart';
import '../view/SplashScreen.dart';


class Routes {
  static const String splashScreen = "/splashScreen";
  static const String onbordingScreen = "/onbordingScreen";
  static const String nameSetScreen = "/nameSetScreen";
  static const String profileSetScreen = "/profileSetScreen";
  static const String bottomNavScreen = "/bottomNavScreen";
  static const String settingScreen = "/settingScreen";
  static const String qrCodeGeneratorScreen = "/qrCodeGeneratorScreen";

  static List<GetPage> pages = [
    GetPage(name: splashScreen, page: () => const SplashScreen()),
    GetPage(name: onbordingScreen, page: () => const Onboardscreen()),
    GetPage(name: bottomNavScreen, page: () => const BottomNavScreen()),
    GetPage(name: nameSetScreen, page: () => const EnterNameScreen()),
    GetPage(name: profileSetScreen, page: () => const ProfileScreen()),
    GetPage(name: settingScreen, page: () => const SettingsScreen()),
    // GetPage(name: qrCodeGeneratorScreen, page: () => const QrCodeGeneratorScreen()),
  ];
}