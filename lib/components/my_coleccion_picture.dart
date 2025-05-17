import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:proyecto_aa/services/storage_service.dart';

class MyColeccionPicture extends StatefulWidget {
  final String coleccionId;
  const MyColeccionPicture({super.key, required this.coleccionId});

  @override
  State<MyColeccionPicture> createState() => _MyColeccionPictureState();
}

class _MyColeccionPictureState extends State<MyColeccionPicture> {
  StorageService storage = StorageService();

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
          height: 150,
          width: 150,
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(8),
            color: Colors.grey.shade300,
            image: pickedImage != null
                ? DecorationImage(
                    fit: BoxFit.cover,
                    image: MemoryImage(pickedImage!),
                  )
                : null,
          ),
          child: pickedImage == null
              ? const Icon(Icons.image, size: 40, color: Colors.white)
              : null,
        ),
      ),
    );
  }

  Future<void> onProfileTaped() async {
    final coleccionId = widget.coleccionId;
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

    await storage.uploadFile('collection_pictures/$coleccionId.jpg', image);

    Navigator.pop(context); // Solo si el upload es exitoso

    final imageBytes = await image.readAsBytes();
    setState(() => pickedImage = imageBytes);
  }

  Future<void> getProfilePicture() async {
    final coleccionId = widget.coleccionId;
    try {
      Uint8List? imageBytes =
          await storage.getFile('collection_pictures/$coleccionId.jpg');
      imageBytes ??=
          await storage.getFile('collection_pictures/$coleccionId.png');
      if (imageBytes == null) return;
      setState(() => pickedImage = imageBytes);
    } catch (e) {
      print('Imagen no encontrada: $e');
      // Opcionalmente muestra un placeholder o simplemente no hagas nada
    }
  }
}
