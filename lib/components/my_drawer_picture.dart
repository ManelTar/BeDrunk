import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:proyecto_aa/services/storage_service.dart';

class MyDrawerPicture extends StatefulWidget {
  const MyDrawerPicture({super.key});

  @override
  State<MyDrawerPicture> createState() => _MyProfilePictureState();
}

class _MyProfilePictureState extends State<MyDrawerPicture> {
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
    return Padding(
      padding: const EdgeInsets.only(left: 13),
      child: GestureDetector(
        onTap: () {
          Scaffold.of(context).openDrawer();
        },
        child: Container(
          height: 200,
          width: 200,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            image: pickedImage != null
                ? DecorationImage(
                    fit: BoxFit.cover,
                    image: Image.memory(pickedImage!, fit: BoxFit.cover).image,
                  )
                : null,
            color: Colors.grey[300], // Placeholder color
          ),
          child: pickedImage == null
              ? const Icon(Icons.person, size: 50, color: Colors.white)
              : null,
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
