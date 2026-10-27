import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:get/get.dart';

import '../../routes/routes.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? imagePath;

  Future<void> pickProfileImage() async {
    final XFile? pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (pickedFile == null) return;

    final directory = await getApplicationDocumentsDirectory();

    final savedImage = await File(
      pickedFile.path,
    ).copy('${directory.path}/profile_image.jpg');

    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('profile_image_path', savedImage.path);

    if (!mounted) return;

    setState(() {
      imagePath = savedImage.path;
    });

    if (savedImage.path.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Image file empty')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile image saved successfully')),
      );

    }
    Get.offNamed(
      Routes.bottomNavScreen,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Set Profile Image',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              CircleAvatar(
                radius: 65,
                backgroundColor: Colors.grey.shade300,
                backgroundImage: imagePath != null
                    ? FileImage(File(imagePath!))
                    : null,
                child: imagePath == null
                    ? const Icon(Icons.person_2_rounded, size: 70)
                    : null,
              ),
              SizedBox(height: 20,),
              ElevatedButton.icon(
                onPressed: pickProfileImage,
                icon: const Icon(Icons.photo_library),
                label: const Text('Choose Image'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
