import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:proyecto_aa/services/storage_service.dart';

class MyDrawerPicture extends StatefulWidget {
  final VoidCallback? onTap;

  const MyDrawerPicture({super.key, this.onTap});

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
      padding: const EdgeInsets.only(top: 0),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          height: 35,
          width: 40,
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
              ? const Icon(Icons.person, size: 35, color: Colors.white)
              : null,
        ),
      ),
    );
  }

  Future<void> getProfilePicture() async {
    final imageBytes = await storage.getFile('profile_pictures/$usuario.jpg');
    if (imageBytes == null) return;

    if (!mounted) return; // 🛡️ Protege de setState después de dispose

    setState(() => pickedImage = imageBytes);
  }
}
