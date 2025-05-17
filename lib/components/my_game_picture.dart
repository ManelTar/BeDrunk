import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:proyecto_aa/services/storage_service.dart';

class MyGamePicture extends StatefulWidget {
  final String gameId;
  const MyGamePicture({super.key, required this.gameId});

  @override
  State<MyGamePicture> createState() => MyGamePictureState();
}

class MyGamePictureState extends State<MyGamePicture> {
  StorageService storage = StorageService();

  Uint8List? pickedImage;

  @override
  void initState() {
    super.initState();
    getProfilePicture();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 13),
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
    );
  }

  Future<void> getProfilePicture() async {
    final gameId = widget.gameId;
    try {
      Uint8List? imageBytes =
          await storage.getFile('games_pictures/$gameId.jpg');
      imageBytes ??= await storage.getFile('games_pictures/$gameId.png');
      if (imageBytes == null) return;
      setState(() => pickedImage = imageBytes);
    } catch (e) {
      print('Imagen no encontrada: $e');
      // Opcionalmente muestra un placeholder o simplemente no hagas nada
    }
  }
}
