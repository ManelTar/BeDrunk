import 'package:cloud_firestore/cloud_firestore.dart';

class Coleccion {
  final String id;
  final String nombre;
  final List<String> juegos;

  Coleccion({
    required this.id,
    required this.nombre,
    required this.juegos,
  });

  factory Coleccion.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Coleccion(
      id: doc.id,
      nombre: data['nombre'],
      juegos: List<String>.from(data['juegos']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'juegos': juegos,
    };
  }
}
