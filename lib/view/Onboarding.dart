import 'package:amarislam/models/constant/app_color.dart';
import 'package:amarislam/routes/routes.dart';
import 'package:amarislam/utils/components/common_image.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:get/get.dart';

import '../models/constant/app_image.dart';
import '../models/constant/app_string.dart';
import '../utils/components/extentions.dart';
import '../utils/components/common_text.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  late AnimationController _floatController;
  late AnimationController _scanController;
  late AnimationController _slideController;
  late AnimationController _pulseController;
  late AnimationController _rippleController;

  late Animation<double> _floatAnimation;
  late Animation<double> _scanAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _rippleAnimation;

  @override
  void initState() {
    super.initState();

    // Float animation for QR icon
    _floatController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
    _floatAnimation = Tween<double>(begin: 0, end: -12).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    // Scan line animation
    _scanController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    _scanAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _scanController, curve: Curves.easeInOut),
    );

    // Slide up + fade animation for bottom section
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );

// Animation শেষ হলে controller stop করে দাও
    _slideController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _slideController.stop();
      }
    });

    _slideController.forward();
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeIn),
    );

    // Pulse for background circles
    _pulseController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat(reverse: true);

    // Ripple on button
    _rippleController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
    _rippleAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _rippleController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _floatController.dispose();
    _scanController.dispose();
    _slideController.dispose();
    _pulseController.dispose();
    _rippleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5A623),
      body: Stack(
        children: [
          // Top yellow section
          _buildTopSection(),
          Align(
            alignment: Alignment.bottomCenter,
            child: SlideTransition(
              position: _slideAnimation,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: _buildBottomSection(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopSection() {
    return Container(
      color: AppColor.primary,
      child: Stack(
        children: [
          // Decorative animated circles
          _buildPulseCircle(top: -30, right: -30, size: 120),
          _buildPulseCircle(top: 80, left: -20, size: 70, delay: 1.0),
          _buildPulseCircle(bottom: 60, right: 30, size: 160, delay: 2.0),

          // Status bar area
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 100),
              child: Center(
                child: _buildQRSection(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPulseCircle({
    double? top,
    double? bottom,
    double? left,
    double? right,
    required double size,
    double delay = 0,
  }) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: AnimatedBuilder(
        animation: _pulseController,
        builder: (context, child) {
          final scale = 1.0 +
              (math.sin((_pulseController.value + delay) * math.pi) * 0.15);
          return Transform.scale(
            scale: scale,
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.12),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildQRSection() {
    return AnimatedBuilder(
      animation: _floatAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _floatAnimation.value),
          child: SizedBox(
            width: 200,
            height: 200,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // QR Code icon
                const Hero(
                  tag: "logoHero",
                  child: CommonImage(
                    imageSrc: AppImage.logo,
                    imageType: ImageType.png,
                    height: 200,
                    width: 200,
                    fill: BoxFit.cover,
                  ),
                ),
                AnimatedBuilder(
                  animation: _scanAnimation,
                  builder: (context, child) {
                    return Positioned(
                      top: 20 + (_scanAnimation.value * 140),
                      left: 15,
                      right: 15,
                      child: Opacity(
                        opacity: _scanAnimation.value < 0.1 ||
                            _scanAnimation.value > 0.9
                            ? 0
                            : 1,
                        child: Container(
                          height: 5,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(2),
                            gradient: const LinearGradient(
                              colors: [
                                Colors.transparent,
                                AppColor.black33,
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomSection() {
    return Container(
      width: double.infinity,
      height: Get.height / 3.5,
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
      decoration: const BoxDecoration(
        color: Color(0xFF2C2C2C),
        borderRadius: BorderRadius.vertical(top: Radius.circular(36)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CommonText(
              text: AppString.getStarted,
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w700,
            ),

            const CommonText(
              text: AppString.gotAndEnjoyOurFeature,
              color: Color(0xFFAAAAAA),
              fontSize: 18,
              maxLines: 2,
              fontWeight: FontWeight.w500,
            ),

            15.height,
            _buildArrowButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildArrowButton() {
    return GestureDetector(
      onTap: () {
        Get.offAllNamed(Routes.bottomNavScreen);
      },
      child: SizedBox(
        width: 100,
        height: 100,
        child: AnimatedBuilder(
          animation: _rippleAnimation,
          builder: (context, child) {
            return Stack(
              alignment: Alignment.center,
              children: [
                // Ripple effect
                Container(
                  width: 52 + (_rippleAnimation.value * 28),
                  height: 52 + (_rippleAnimation.value * 28),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFF5A623)
                        .withValues(alpha: 0.4 * (1 - _rippleAnimation.value)),
                  ),
                ),
                // Button
                Container(
                  width: 52,
                  height: 52,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFFF5A623),
                  ),
                  child: const Icon(
                    Icons.arrow_forward_rounded,
                    color: Color(0xFF1A1A1A),
                    size: 24,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
