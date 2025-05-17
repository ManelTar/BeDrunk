import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'dart:io';

class StorageService {
  StorageService() : ref = FirebaseStorage.instance.ref();

  final Reference ref;

  Future<void> uploadFile(String fileName, XFile file) async {
    try {
      final imageRef = ref.child(fileName);

      // 🔽 Leer como File
      final originalFile = File(file.path);

      // 🔧 Comprimir
      final compressedBytes = await FlutterImageCompress.compressWithFile(
        originalFile.absolute.path,
        minWidth: 800, // puedes ajustar la resolución
        minHeight: 800,
        quality: 70, // calidad del 0 al 100
        format: CompressFormat.jpeg,
      );

      if (compressedBytes == null) {
        print('No se pudo comprimir la imagen.');
        return;
      }

      // ☁️ Subir
      await imageRef.putData(compressedBytes);
      print('Imagen comprimida subida con éxito.');
    } catch (e) {
      print('Error al subir el archivo: $e');
    }
  }

  Future<Uint8List?> getFile(String fileName) async {
    try {
      final imageRef = ref.child(fileName);
      return imageRef.getData();
    } catch (e) {
      print('Error al descargar el archivo: $e');
      return null;
    }
  }
}
