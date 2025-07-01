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
  final List<String> usedQuestionIds;
  final String? mostVotedUid;
  final String? leastVotedUid;
  final Map<String, dynamic> votes;

  Game({
    required this.id,
    required this.hostId,
    required this.estado,
    required this.players,
    required this.status,
    required this.currentQuestionText,
    required this.round,
    this.resultUid,
    required this.usedQuestionIds,
    required this.mostVotedUid,
    required this.leastVotedUid,
    required this.votes,
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
      mostVotedUid: data['mostVotedUid'],
      leastVotedUid: data['leastVotedUid'],
      currentQuestionText: data['currentQuestionText'],
      resultUid: data['resultUid'],
      players: players,
      usedQuestionIds:
          (data['usedQuestionIds'] as List?)?.whereType<String>().toList() ??
              [],
      votes: Map<String, dynamic>.from(data['votes'] ?? {}), // <- nuevo
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'estado': estado,
      'hostId': hostId,
      'players': players.map((p) => p.toMap()).toList(),
      'status': status,
      'currentQuestionText': currentQuestionText,
      'mostVotedUid': mostVotedUid,
      'leastVotedUid': leastVotedUid,
      'round': round,
      'resultUid': resultUid,
      'usedQuestionIds': usedQuestionIds,
      'votes': votes,
    };
  }
}
