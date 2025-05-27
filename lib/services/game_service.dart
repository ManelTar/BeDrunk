import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:proyecto_aa/models/game.dart';
import '../models/player.dart';

class GameService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final _games = FirebaseFirestore.instance.collection('games');
  final _questions = FirebaseFirestore.instance.collection('preguntas');

  /// Devuelve una pregunta aleatoria del tipo "prefieres" que no se haya usado
  Future<Map<String, dynamic>> getUniquePrefieresQuestion(
      List<String> usedIds) async {
    final snapshot =
        await _questions.where('tipo', isEqualTo: 'prefieres').get();

    final unused =
        snapshot.docs.where((doc) => !usedIds.contains(doc.id)).toList();

    if (unused.isEmpty) {
      return {
        'id': 'none',
        'pregunta': 'Ya se usaron todas las preguntas disponibles.'
      };
    }

    final randomDoc = unused[Random().nextInt(unused.length)];
    return {
      'id': randomDoc.id,
      'pregunta': randomDoc['pregunta'],
    };
  }

  /// Crea una nueva partida con pregunta inicial
  Future<String> createGame(Player host) async {
    final snapshot =
        await _questions.where('tipo', isEqualTo: 'prefieres').get();

    if (snapshot.docs.isEmpty) throw Exception("No hay preguntas disponibles.");

    final doc = snapshot.docs[Random().nextInt(snapshot.docs.length)];
    final questionText = doc.data()['pregunta'] ?? "Pregunta no válida.";

    final gameId = await _generateUniqueGameCode();
    final gameDoc = _games.doc(gameId);

    await gameDoc.set({
      'estado': 'lobby',
      'hostId': host.uid,
      'status': 'waiting',
      'players': [host.toMap()],
      'round': 1,
      'currentQuestionText': questionText,
      'usedQuestionIds': [doc.id],
      'resultUid': null,
      'createdAt': FieldValue.serverTimestamp(),
    });

    return gameId;
  }

  /// Un jugador se une a la partida
  Future<void> joinGame(String gameId, Player player) async {
    final gameRef = _games.doc(gameId);
    await gameRef.update({
      'players': FieldValue.arrayUnion([player.toMap()])
    });
  }

  /// Comienza la partida
  Future<void> startGame(String gameId) async {
    final gameRef = _games.doc(gameId);
    final gameSnap = await gameRef.get();
    final game = Game.fromFirestore(gameSnap);

    // Obtener las preguntas ya usadas
    final usedIds = game.usedQuestionIds;

    // Obtener una nueva pregunta que no se haya usado
    final next = await getUniquePrefieresQuestion(usedIds);
    final newQuestionText = next['pregunta'] ?? 'Sin pregunta';
    final newQuestionId = next['id'];

    // Marcar todos los jugadores como no votados
    final updatedPlayers = game.players
        .map((p) => p.copyWith(hasVoted: false, voteTo: null))
        .toList();

    await gameRef.update({
      'status': 'playing',
      'round': game.round + 1,
      'currentQuestionText': newQuestionText,
      'resultUid': null,
      'players': updatedPlayers.map((p) => p.toMap()).toList(),
      'usedQuestionIds': [...usedIds, newQuestionId],
    });
  }

  /// Un jugador emite su voto
  Future<void> submitVote(
      String gameId, String voterUid, String votedUid) async {
    final gameRef = _games.doc(gameId);
    final gameSnap = await gameRef.get();
    final game = Game.fromFirestore(gameSnap);

    final updatedPlayers = game.players.map((p) {
      if (p.uid == voterUid) {
        return p.copyWith(hasVoted: true, voteTo: votedUid);
      }
      return p;
    }).toList();

    await gameRef.update({
      'players': updatedPlayers.map((p) => p.toMap()).toList(),
    });

    final allVoted = updatedPlayers.every((p) => p.hasVoted);

    if (allVoted) {
      final votes = <String, int>{};
      for (final p in updatedPlayers) {
        if (p.voteTo != null) {
          votes[p.voteTo!] = (votes[p.voteTo!] ?? 0) + 1;
        }
      }

      final resultUid = votes.entries.isNotEmpty
          ? votes.entries.reduce((a, b) => a.value >= b.value ? a : b).key
          : null;

      await gameRef.update({'resultUid': resultUid});
    }
  }

  /// Verifica votos y pasa de ronda
  Future<void> checkVotesAndAdvance(String gameId) async {
    final gameRef = _games.doc(gameId);
    final snapshot = await gameRef.get();
    final data = snapshot.data();
    if (data == null) return;

    List players = data['players'];
    final allVoted = players.every((p) => p['hasVoted'] == true);

    if (allVoted) {
      Map<String, int> voteCounts = {};
      for (final player in players) {
        final voteTo = player['voteTo'];
        if (voteTo != null) {
          voteCounts[voteTo] = (voteCounts[voteTo] ?? 0) + 1;
        }
      }

      final mostVoted = voteCounts.entries.isNotEmpty
          ? voteCounts.entries.reduce((a, b) => a.value > b.value ? a : b).key
          : null;

      for (var p in players) {
        p['hasVoted'] = false;
        p['voteTo'] = null;
      }

      final usedIds = List<String>.from(data['usedQuestionIds'] ?? []);
      final next = await getUniquePrefieresQuestion(usedIds);

      await gameRef.update({
        'resultUid': mostVoted,
        'round': data['round'] + 1,
        'players': players,
        'currentQuestionText': next['pregunta'],
        'usedQuestionIds': FieldValue.arrayUnion([next['id']]),
      });
    }
  }

  Future<String> _generateUniqueGameCode() async {
    final random = Random();
    String code;
    bool exists = true;

    do {
      code = (random.nextInt(90000) + 10000).toString();
      final doc = await _games.doc(code).get();
      exists = doc.exists;
    } while (exists);

    return code;
  }
}
