import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:proyecto_aa/models/game.dart';
import 'package:proyecto_aa/services/user_service.dart';
import '../models/player.dart';

class GameService {
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

    UserService().anadirPartidasTotales(player.uid);
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
      'mostVotedUid': '',
      'leastVotedUid': '',
      'usedQuestionIds': [...usedIds, newQuestionId],
    });
  }

  /// Un jugador emite su voto
  Future<void> submitVote(
      String gameId, String voterUid, String votedUid) async {
    final gameRef = _games.doc(gameId);

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final gameSnap = await transaction.get(gameRef);
      final game = Game.fromFirestore(gameSnap);
      final players = [...game.players];

      // Buscar al votante
      final voterIndex = players.indexWhere((p) => p.uid == voterUid);
      if (voterIndex != -1) {
        players[voterIndex] = players[voterIndex].copyWith(
          hasVoted: true,
          voteTo: votedUid,
        );
      }

      // Sumar el voto al jugador votado
      final votedIndex = players.indexWhere((p) => p.uid == votedUid);
      if (votedIndex != -1) {
        final currentCount = players[votedIndex].votedCount;
        players[votedIndex] = players[votedIndex].copyWith(
          votedCount: currentCount + 1,
        );
      }

      transaction.update(gameRef, {
        'players': players.map((p) => p.toMap()).toList(),
      });

      final allVoted = players.every((p) => p.hasVoted);

      if (allVoted) {
        final votes = <String, int>{};
        for (final p in players) {
          if (p.voteTo != null) {
            votes[p.voteTo!] = (votes[p.voteTo!] ?? 0) + 1;
          }
        }

        final resultUid = votes.entries.isNotEmpty
            ? votes.entries.reduce((a, b) => a.value >= b.value ? a : b).key
            : null;

        transaction.update(gameRef, {'resultUid': resultUid});
      }
    });
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

  Future<void> leaveGame(String gameId, String playerUid) async {
    final gameRef = _games.doc(gameId);
    final snapshot = await gameRef.get();

    if (!snapshot.exists) return;

    final game = Game.fromFirestore(snapshot);

    // Si el que sale es el host, NO lo eliminamos, solo terminamos el juego
    if (game.hostId == playerUid) {
      await endGame(gameId);
    } else {
      // Si es un jugador normal, lo eliminamos del array
      final updatedPlayers =
          game.players.where((p) => p.uid != game.hostId).toList();

      await gameRef.update({
        'players': updatedPlayers.map((p) => p.toMap()).toList(),
      });
    }
  }

  Future<void> endGame(String gameId) async {
    final gameRef = FirebaseFirestore.instance.collection('games').doc(gameId);
    final snapshot = await gameRef.get();

    if (!snapshot.exists) return;

    final game = Game.fromFirestore(snapshot);
    final players = game.players;

    if (players.isEmpty) {
      await gameRef.update({'status': 'ended'});
      return;
    }

    // Jugadores con al menos un voto (para evitar empates forzados en 0)
    final playersWithVotes = players.where((p) => p.votedCount > 0).toList();

    // Si nadie recibió votos, termina sin resultado
    if (playersWithVotes.isEmpty) {
      await gameRef.update({'status': 'ended'});
      return;
    }

    // Más votado
    final mostVotedPlayer = playersWithVotes.reduce(
      (a, b) => a.votedCount >= b.votedCount ? a : b,
    );

    UserService().anadirPartidaGanada(mostVotedPlayer.uid);

    // Menos votado (de los que recibieron votos)
    final leastVotedPlayer = playersWithVotes.reduce(
      (a, b) => a.votedCount <= b.votedCount ? a : b,
    );

    UserService().anadirPartidaPerdida(leastVotedPlayer.uid);

    await gameRef.update({
      'status': 'ended',
      'mostVotedUid': mostVotedPlayer.uid,
      'leastVotedUid': leastVotedPlayer.uid,
    });
  }
}
