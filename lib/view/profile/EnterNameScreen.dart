import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';

import '../../routes/routes.dart';

class EnterNameScreen extends StatefulWidget {
  const EnterNameScreen({super.key});

  @override
  State<EnterNameScreen> createState() => _EnterNameScreenState();
}

class _EnterNameScreenState extends State<EnterNameScreen> {
  final TextEditingController nameController = TextEditingController();
  bool isSaving = false;

  Future<void> saveName() async {
    final name = nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter your name')));
      return;
    }
    setState(() => isSaving = true);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', name);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("successfully save the name")));

    Get.offNamed(Routes.profileSetScreen);

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'What is your name?',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: nameController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Your name',
                hintText: 'Enter your name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person_outline),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isSaving ? null : saveName,
                child: isSaving
                    ? const CircularProgressIndicator()
                    : const Text('Continue'),
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => {
                  Get.offNamed(
                    Routes.profileSetScreen,
                  )
                },
                child: const Text('skip'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }
}
