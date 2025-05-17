import 'package:cloud_firestore/cloud_firestore.dart';

class Juego {
  final String nombre;
  final int jugadoresMax;
  final String reglas;
  final String descripcion;
  final String gif;
  final String foto;
  final bool jugable;
  final String tipo;

  Juego({
    required this.nombre,
    required this.jugadoresMax,
    required this.reglas,
    required this.descripcion,
    required this.gif,
    required this.foto,
    required this.jugable,
    required this.tipo,
  });

  factory Juego.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Juego(
      nombre: doc.id,
      jugadoresMax: data['JugadoresMax'],
      descripcion: data['Descripcion'],
      gif: data['Gif'],
      foto: data['foto'],
      reglas: data['Instrucciones'],
      jugable: data['Jugable'] ?? false,
      tipo: data['Tipo'] ?? '',
    );
  }
}
