import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FavService {
  final usuario = FirebaseAuth.instance.currentUser!.uid;

  void saveFav(String nombreJuego) async {
    try {
      await FirebaseFirestore.instance
          .collection('favoritos')
          .doc(usuario)
          .set({
        'juegos': FieldValue.arrayUnion([nombreJuego]),
      }, SetOptions(merge: true));
    } catch (e) {
      ;
    }
  }

  Future<List<String>> getFav() async {
    try {
      final documentSnapshot = await FirebaseFirestore.instance
          .collection('favoritos')
          .doc(usuario)
          .get();

      if (documentSnapshot.exists) {
        List<dynamic> juegos = documentSnapshot['juegos'];
        return List<String>.from(juegos);
      } else {
        return []; // No hay favoritos
      }
    } catch (e) {
      print('Error al obtener los juegos favoritos: $e');
      return []; // En caso de error, devolvemos una lista vacía
    }
  }

  removeFav(String nombreJuego) async {
    try {
      await FirebaseFirestore.instance
          .collection('favoritos')
          .doc(usuario)
          .update({
        'juegos': FieldValue.arrayRemove([nombreJuego]),
      });
    } catch (e) {
      print('Error al eliminar favorito: $e');
    }
  }
}
