import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:proyecto_aa/screens/user_page.dart';
import 'package:proyecto_aa/services/storage_service.dart';

class MyProfilePicture extends StatefulWidget {
  const MyProfilePicture({super.key});

  @override
  State<MyProfilePicture> createState() => _MyProfilePictureState();
}

class _MyProfilePictureState extends State<MyProfilePicture> {
  StorageService storage = StorageService();
  final usuario = FirebaseAuth.instance.currentUser!.uid;
  Uint8List? pickedImage;

  @override
  void initState() {
    super.initState();
    getProfilePicture();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => UserPage()),
        );
      },
      child: Padding(
        padding: EdgeInsets.only(bottom: 13),
        child: Container(
          height: 100,
          width: 100,
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: pickedImage != null
                  ? DecorationImage(
                      fit: BoxFit.scaleDown,
                      image: Image.memory(pickedImage!, fit: BoxFit.scaleDown)
                          .image)
                  : null),
        ),
      ),
    );
  }

  Future<void> getProfilePicture() async {
    final imageBytes = await storage.getFile('profile_pictures/$usuario.jpg');
    if (imageBytes == null) return;
    setState(() => pickedImage = imageBytes);
  }
}
