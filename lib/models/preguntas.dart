import 'package:cloud_firestore/cloud_firestore.dart';

class Preguntas {
  final String pregunta;
  final String tipo;

  Preguntas({
    required this.pregunta,
    required this.tipo,
  });

  factory Preguntas.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Preguntas(
      pregunta: data['Pregunta'] ?? '',
      tipo: data['Tipo'] ?? '',
    );
  }
}
