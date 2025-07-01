import 'package:cloud_firestore/cloud_firestore.dart';

class UserService {
  Future<void> anadirTrago(final uid) async {
    // Implement the logic to add a drink
    final userRef = FirebaseFirestore.instance.collection('users');

    await userRef
        .doc(uid)
        .set({'tragos': FieldValue.increment(1)}, SetOptions(merge: true));
  }

  Future<void> anadirPartidasTotales(final uid) async {
    // Implement the logic to add total games
    final userRef = FirebaseFirestore.instance.collection('users');

    await userRef.doc(uid).set(
        {'partidasTotales': FieldValue.increment(1)}, SetOptions(merge: true));
  }

  Future<void> anadirPartidaGanada(final uid) async {
    // Implement the logic to add a won game
    final userRef = FirebaseFirestore.instance.collection('users');

    await userRef.doc(uid).set(
        {'partidasGanadas': FieldValue.increment(1)}, SetOptions(merge: true));
  }

  Future<void> anadirPartidaPerdida(final uid) async {
    // Implement the logic to add a lost game
    final userRef = FirebaseFirestore.instance.collection('users');

    await userRef.doc(uid).set(
        {'partidasPerdidas': FieldValue.increment(1)}, SetOptions(merge: true));
  }
}
