import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:proyecto_aa/models/player.dart';
import 'package:proyecto_aa/screens/result_final_page.dart';
import 'package:proyecto_aa/screens/result_page.dart';
import '../models/game.dart';
import '../services/game_service.dart';

class PrefieresPage extends StatefulWidget {
  final String gameId;
  const PrefieresPage({super.key, required this.gameId});

  @override
  State<PrefieresPage> createState() => _PrefieresPageState();
}

class _PrefieresPageState extends State<PrefieresPage> {
  bool _navegado = false;
  @override
  Widget build(BuildContext context) {
    final gameRef =
        FirebaseFirestore.instance.collection('games').doc(widget.gameId);

    return StreamBuilder<DocumentSnapshot>(
      stream: gameRef.snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return Scaffold(
              body: Center(
                  child: LoadingAnimationWidget.stretchedDots(
                      color: Theme.of(context).colorScheme.primary, size: 75)));
        final game = Game.fromFirestore(snapshot.data!);
        final userId = FirebaseAuth.instance.currentUser!.uid;
        final me = game.players.firstWhere(
          (p) => p.uid == userId,
          orElse: () => Player(uid: '', name: 'Desconocido', photoUrl: ''),
        );

        final hasVoted = me.hasVoted;

        if (game.status == 'ended' && !_navegado) {
          _navegado = true;

          Future.microtask(() {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => ResultadoFinalPage(gameId: game.id),
              ),
            );
          });
        }

        if (game.resultUid != null) {
          // Todos han votado, mostrar resultados
          return ResultPage(gameId: game.id);
        }

        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surfaceTint,
          appBar: AppBar(
            title: Text('Ronda ${game.round - 1}'),
            backgroundColor: Theme.of(context).colorScheme.surfaceTint,
            actions: [
              IconButton(
                onPressed: () async {
                  final uid = FirebaseAuth.instance.currentUser!.uid;
                  await GameService().leaveGame(widget.gameId, uid);

                  if (me.uid != game.hostId) {
                    Navigator.popUntil(context, (route) => route.isFirst);
                  }
                },
                icon: Icon(Icons.exit_to_app),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
          body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Text(game.currentQuestionText,
                    textAlign: TextAlign.center,
                    style:
                        TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              ),
              SizedBox(height: 30),
              if (hasVoted)
                AnimatedTextKit(
                  animatedTexts: [
                    WavyAnimatedText('Esperando al resto...',
                        textStyle: GoogleFonts.battambang(
                            textStyle: TextStyle(fontSize: 16)),
                        speed: Duration(milliseconds: 150)),
                  ],
                  isRepeatingAnimation: true,
                  onTap: () {},
                )
              else
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: game.players
                      .map((p) => GestureDetector(
                            onTap: () async {
                              await GameService()
                                  .submitVote(game.id, userId, p.uid);
                            },
                            child: Card(
                              elevation: 15,
                              shadowColor: Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerHighest,
                              child: Padding(
                                padding: EdgeInsets.all(15),
                                child: Column(
                                  children: [
                                    CircleAvatar(
                                        radius: 30,
                                        backgroundImage:
                                            NetworkImage(p.photoUrl)),
                                    const SizedBox(
                                      height: 4,
                                    ),
                                    Text(
                                      p.name,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ))
                      .toList(),
                ),
            ],
          ),
        );
      },
    );
  }
}
