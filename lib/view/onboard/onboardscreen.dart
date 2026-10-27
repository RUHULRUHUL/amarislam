import 'dart:ffi';

import 'package:amarislam/routes/routes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/model/Onboard_model.dart';
import 'onboardpage.dart';

class Onboardscreen extends StatefulWidget {
  const Onboardscreen({super.key});

  @override
  State<Onboardscreen> createState() => _OnboardscreenState();
}

class _OnboardscreenState extends State<Onboardscreen> {
  final PageController _pageController = PageController();

  int _currentPage = 0;

  final List<OnboardingModel> _pages = const [
    OnboardingModel(
      image: 'assets/images/splash_screen.png',
      title: 'Scan Anything',
      description:
          'Quickly scan QR codes and barcodes with our fast and simple scanner.',
    ),
    OnboardingModel(
      image: 'assets/images/mosjid.jpg',
      title: 'Easy & Fast',
      description:
          'Scan codes easily using your camera or select an image from your gallery.',
    ),
    OnboardingModel(
      image: 'assets/images/splash_screen.png',
      title: 'Everything in One Place',
      description:
          'Keep your scan history organized and access your scanned information anytime.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: _pages.length,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemBuilder: (context, index) {
                final page = _pages[index];

                return OnboardingPage(
                  image: page.image,
                  title: page.title,
                  description: page.description,
                );
              },
            ),
          ),
          //dot indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_pages.length, (index) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: _currentPage == index ? 24 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _currentPage == index ? Colors.blue : Colors.grey,
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }),
          ),
          const SizedBox(height: 20),
          // Next Button
          Padding(
            padding: const EdgeInsets.all(30.0),
            child: SizedBox(
              width: double.infinity,
              height: 40,
              child: ElevatedButton(onPressed: () {
                Get.offNamed(
                  Routes.nameSetScreen,
                );
              }, child: Text(
                _currentPage == _pages.length-1 ? "Get Started" : "Next"
              )),
            ),
          ),
        ],
      ),
    );
  }
}
