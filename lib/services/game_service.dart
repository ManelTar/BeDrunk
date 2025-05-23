import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:proyecto_aa/models/game.dart';
import '../models/player.dart';

class GameService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final _games = FirebaseFirestore.instance.collection('games');
  final _questions = FirebaseFirestore.instance.collection('preguntas');

  /// Devuelve una pregunta aleatoria del tipo "prefieres"
  Future<String> getRandomPrefieresQuestion() async {
    final snapshot =
        await _questions.where('tipo', isEqualTo: 'prefieres').get();

    if (snapshot.docs.isEmpty) {
      return "No hay preguntas disponibles.";
    }

    final random = Random();
    final doc = snapshot.docs[random.nextInt(snapshot.docs.length)];
    return doc.data()['pregunta'] ?? "Pregunta no válida.";
  }

  /// Crea una nueva partida con una pregunta inicial
  Future<String> createGame(Player host) async {
    final question = await getRandomPrefieresQuestion();
    final gameId = await _generateUniqueGameCode();

    final gameDoc = _games.doc(gameId); // usamos .doc(id) en vez de .add()

    await gameDoc.set({
      'estado': 'lobby',
      'hostId': host.uid,
      'status': 'waiting',
      'players': [host.toMap()],
      'round': 1,
      'currentQuestionText': question,
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

  /// Comienza la partida (opcional si quieres forzar un nuevo comienzo)
  Future<void> startGame(String gameId, String nextQuestion) async {
    final gameRef = _games.doc(gameId);
    final gameSnap = await gameRef.get();
    final data = gameSnap.data()!;
    final players = (data['players'] as List)
        .map((p) => {
              ...p,
              'hasVoted': false,
              'voteTo': null,
            })
        .toList();

    final newQuestion = await getRandomPrefieresQuestion();

    await gameRef.update({
      'status': 'playing',
      'round': data['round'] + 1,
      'currentQuestionText': newQuestion,
      'resultUid': null,
      'players': players,
    });
  }

  /// Un jugador emite su voto
  Future<void> submitVote(
      String gameId, String voterUid, String votedUid) async {
    final gameRef = FirebaseFirestore.instance.collection('games').doc(gameId);
    final gameSnap = await gameRef.get();
    final game = Game.fromFirestore(gameSnap);

    // Actualiza hasVoted del jugador que votó
    final updatedPlayers = game.players.map((p) {
      if (p.uid == voterUid) {
        return p.copyWith(hasVoted: true, voteTo: votedUid);
      }
      return p;
    }).toList();

    await gameRef.update({
      'players': updatedPlayers.map((p) => p.toMap()).toList(),
    });

    // Verifica si todos han votado
    final allVoted = updatedPlayers.every((p) => p.hasVoted == true);

    if (allVoted) {
      // Contar votos
      final votes = <String, int>{};
      for (final p in updatedPlayers) {
        if (p.voteTo != null) {
          votes[p.voteTo!] = (votes[p.voteTo!] ?? 0) + 1;
        }
      }

      // Elegir UID con más votos
      final resultUid =
          votes.entries.reduce((a, b) => a.value >= b.value ? a : b).key;

      await gameRef.update({'resultUid': resultUid});
    }
  }

  /// Verifica si todos votaron, guarda resultados y avanza de ronda
  Future<void> checkVotesAndAdvance(String gameId) async {
    final gameRef = _games.doc(gameId);
    final snapshot = await gameRef.get();
    final data = snapshot.data();
    if (data == null) return;

    List players = data['players'];
    final allVoted = players.every((p) => p['hasVoted'] == true);

    if (allVoted) {
      // Calcular el jugador más votado
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

      // Preparar la siguiente ronda
      for (var p in players) {
        p['hasVoted'] = false;
        p['voteTo'] = null;
      }

      final newQuestion = await getRandomPrefieresQuestion();

      await gameRef.update({
        'resultUid': mostVoted,
        'round': data['round'] + 1,
        'players': players,
        'currentQuestionText': newQuestion,
      });
    }
  }

  Future<String> _generateUniqueGameCode() async {
    final random = Random();
    String code;
    bool exists = true;

    do {
      code = (random.nextInt(90000) + 10000)
          .toString(); // genera entre 10000 y 99999
      final doc = await _games.doc(code).get();
      exists = doc.exists;
    } while (exists);

    return code;
  }
}
