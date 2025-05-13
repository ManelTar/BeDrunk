import 'package:cloud_firestore/cloud_firestore.dart';

class Juego {
  final String nombre;
  final int jugadoresMin;
  final int jugadoresMax;
  final String reglas;
  final String descripcion;
  final String gif;

  Juego({
    required this.nombre,
    required this.jugadoresMin,
    required this.jugadoresMax,
    required this.reglas,
    required this.descripcion,
    required this.gif,
  });

  factory Juego.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Juego(
      nombre: doc.id,
      jugadoresMin: data['JugadoresMin'],
      jugadoresMax: data['JugadoresMax'],
      descripcion: data['Descripcion'],
      gif: data['Gif'],
      reglas: data['Instrucciones'],
    );
  }
}
