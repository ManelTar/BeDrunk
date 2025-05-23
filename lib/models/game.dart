import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:proyecto_aa/models/player.dart';

class Game {
  final String id;
  final String hostId;
  final String estado;
  final List<Player> players;
  final String status;
  final String currentQuestionText;
  final int round;
  final String? resultUid;

  Game({
    required this.id,
    required this.hostId,
    required this.estado,
    required this.players,
    required this.status,
    required this.currentQuestionText,
    required this.round,
    this.resultUid,
  });

  factory Game.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    final players = (data['players'] as List)
        .map((p) => Player.fromMap(p as Map<String, dynamic>))
        .toList();

    return Game(
      id: doc.id,
      estado: data['estado'],
      hostId: data['hostId'],
      status: data['status'],
      round: data['round'],
      currentQuestionText: data['currentQuestionText'],
      resultUid: data['resultUid'],
      players: players,
    );
  }
}
