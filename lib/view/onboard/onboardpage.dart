import 'package:flutter/material.dart';

class OnboardingPage extends StatelessWidget {
  final String image;
  final String title;
  final String description;

  const OnboardingPage({
    super.key,
    required this.image,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        children: [
          const SizedBox(height: 70),

          // Image
          Expanded(
            flex: 5,
            child: Image.asset(
              image,
              fit: BoxFit.contain,
            ),
          ),

          const SizedBox(height: 30),

          // Title
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 16),

          // Description
          Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              height: 1.5,
              color: Colors.grey.shade600,
            ),
          ),

          const Spacer(),
        ],
      ),
    );
  }
}