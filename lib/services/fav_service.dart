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

  Future<void> removeFavColeccion(String nombreJuego) async {
    final usuario = FirebaseAuth.instance.currentUser!.uid;

    try {
      final coleccionesSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(usuario)
          .collection('colecciones')
          .get();

      for (final coleccion in coleccionesSnapshot.docs) {
        final juegos = List<String>.from(coleccion['juegos'] ?? []);

        if (juegos.contains(nombreJuego)) {
          await coleccion.reference.update({
            'juegos': FieldValue.arrayRemove([nombreJuego]),
          });
          print(
              'Juego "$nombreJuego" eliminado de colección "${coleccion.id}"');
        }
      }
    } catch (e) {
      print('Error al eliminar el juego de las colecciones: $e');
    }
  }

  Future<void> removeColeccion(String coleccionId) async {
    final usuario = FirebaseAuth.instance.currentUser!.uid;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(usuario)
          .collection('colecciones')
          .doc(coleccionId)
          .delete();
      print('Colección "$coleccionId" eliminada con éxito.');
    } catch (e) {
      print('Error al eliminar la colección: $e');
    }
  }
}
