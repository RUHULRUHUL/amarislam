import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:amarislam/routes/routes.dart';
import 'package:flutter/material.dart';

import '../models/constant/app_color.dart';
import '../models/constant/app_image.dart';
import '../utils/components/common_image.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {

  late AnimationController controller;
  late Animation<double> animation;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    animation = Tween<double>(begin: 0.8, end: 1.2).animate(controller);

    Timer(const Duration(seconds: 2), () {
      if (mounted) {
        Get.offNamed(
          Routes.onbordingScreen,
        );
      }
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.primary,
      body: Center(
        child: Hero(
          tag: "logoHero", // ✅ MUST not be null
          child: ScaleTransition(
            scale: animation,
            child: const CommonImage(
              imageSrc: "assets/images/splash_screen.png",
              imageType: ImageType.png,
              height: 200,
              width: 200,
              fill: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }
}