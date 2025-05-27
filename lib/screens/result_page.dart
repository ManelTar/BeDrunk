import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:proyecto_aa/models/player.dart';
import '../models/game.dart';
import '../services/game_service.dart';

class ResultPage extends StatelessWidget {
  final String gameId;
  const ResultPage({super.key, required this.gameId});

  @override
  Widget build(BuildContext context) {
    final gameRef = FirebaseFirestore.instance.collection('games').doc(gameId);

    return StreamBuilder<DocumentSnapshot>(
      stream: gameRef.snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return Scaffold(body: Center(child: CircularProgressIndicator()));
        final game = Game.fromFirestore(snapshot.data!);
        final resultPlayer = game.players.firstWhere(
            (p) => p.uid == game.resultUid,
            orElse: () =>
                Player(uid: '', name: 'Nadie', photoUrl: '', hasVoted: false));

        final isHost = FirebaseAuth.instance.currentUser!.uid == game.hostId;

        return Scaffold(
          appBar: AppBar(title: Text("Resultado")),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("La persona más votada fue:",
                    style: TextStyle(fontSize: 20)),
                SizedBox(height: 20),
                CircleAvatar(
                    radius: 40,
                    backgroundImage: NetworkImage(resultPlayer.photoUrl)),
                SizedBox(height: 10),
                Text(resultPlayer.name,
                    style:
                        TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                SizedBox(height: 30),
                if (isHost)
                  ElevatedButton(
                    onPressed: () async {
                      await GameService().startGame(game.id);
                    },
                    child: Text("Siguiente Ronda"),
                  )
                else
                  Text("Esperando al host...",
                      style:
                          TextStyle(fontSize: 16, fontStyle: FontStyle.italic)),
              ],
            ),
          ),
        );
      },
    );
  }
}
