import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:proyecto_aa/services/storage_service.dart';

class MyCardPicture extends StatefulWidget {
  const MyCardPicture({super.key, required this.coleccionId});

  final String coleccionId;

  @override
  State<MyCardPicture> createState() => _MyCardPictureState();
}

class _MyCardPictureState extends State<MyCardPicture> {
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
      child: Padding(
        padding: EdgeInsets.only(bottom: 0),
        child: Container(
          height: 50,
          width: 50,
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

  Future<void> getProfilePicture() async {
    final coleccionId = widget.coleccionId;
    try {
      final imageBytes =
          await storage.getFile('collection_pictures/$coleccionId.jpg');
      if (imageBytes == null) return;
      setState(() => pickedImage = imageBytes);
    } catch (e) {
      print('Imagen no encontrada: $e');
      // Opcionalmente muestra un placeholder o simplemente no hagas nada
    }
  }
}
