import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
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
      onTap: onProfileTaped,
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

  Future<void> onProfileTaped() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    showDialog(
        context: context,
        builder: (context) {
          return Center(
            child: LoadingAnimationWidget.stretchedDots(
              color: Theme.of(context).colorScheme.primary,
              size: 75,
            ),
          );
        });

    await storage.uploadFile('profile_pictures/$usuario.jpg', image);

    Navigator.pop(context); // Solo si el upload es exitoso

    final imageBytes = await image.readAsBytes();
    setState(() => pickedImage = imageBytes);
  }

  Future<void> getProfilePicture() async {
    final imageBytes = await storage.getFile('profile_pictures/$usuario.jpg');
    if (imageBytes == null) return;
    setState(() => pickedImage = imageBytes);
  }
}
