import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:proyecto_aa/services/storage_service.dart';

class MyChangablePicture extends StatefulWidget {
  const MyChangablePicture({super.key});

  @override
  State<MyChangablePicture> createState() => _MyChangablePictureState();
}

class _MyChangablePictureState extends State<MyChangablePicture> {
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
        onProfileTaped();
      },
      child: Padding(
        padding: EdgeInsets.only(bottom: 13),
        child: Container(
          height: 200,
          width: 200,
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: pickedImage != null
                  ? DecorationImage(
                      fit: BoxFit.cover,
                      image:
                          Image.memory(pickedImage!, fit: BoxFit.cover).image)
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
