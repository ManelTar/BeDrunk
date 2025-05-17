import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:proyecto_aa/models/juego.dart';

Future<Juego?> obtenerJuegoDelDia() async {
  final snapshot = await FirebaseFirestore.instance.collection('juegos').get();
  final juegos = snapshot.docs;

  if (juegos.isEmpty) return null;

  final now = DateTime.now();
  final index = now.day % juegos.length; // cambia cada día
  final doc = juegos[index];

  return Juego(
    nombre: doc.id,
    jugadoresMax: doc['JugadoresMax'],
    reglas: doc['Instrucciones'],
    descripcion: doc['Descripcion'],
    gif: doc['Gif'],
    foto: doc['foto'],
    jugable: doc['Jugable'] ?? false,
    tipo: doc['Tipo'] ?? '',
  );
}
