import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:proyecto_aa/models/game.dart';
import 'package:proyecto_aa/screens/prefieres_page.dart';
import 'package:proyecto_aa/services/game_service.dart';

class LobbyPage extends StatefulWidget {
  final String gameId;

  const LobbyPage({super.key, required this.gameId});

  @override
  State<LobbyPage> createState() => _LobbyPageState();
}

class _LobbyPageState extends State<LobbyPage> {
  bool yaNavegado = false;

  @override
  Widget build(BuildContext context) {
    final gameRef =
        FirebaseFirestore.instance.collection('games').doc(widget.gameId);

    return StreamBuilder<DocumentSnapshot>(
      stream: gameRef.snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return CircularProgressIndicator();

        final game = Game.fromFirestore(snapshot.data!);
        final isHost = game.hostId == FirebaseAuth.instance.currentUser!.uid;

        // Si el estado del juego es 'jugando', navegar a PrefieresPage
        if (game.status == 'playing' && !yaNavegado) {
          yaNavegado = true;

          // Usar Future.microtask para evitar problemas con Navigator en build
          Future.microtask(() {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => PrefieresPage(gameId: game.id),
              ),
            );
          });
        }

        return Scaffold(
          appBar: AppBar(title: Text('Lobby')),
          body: Column(
            children: [
              Text(
                widget.gameId,
                style:
                    GoogleFonts.battambang(textStyle: TextStyle(fontSize: 40)),
              ),
              Text('Jugadores conectados:'),
              ...game.players.map((p) => Align(
                    alignment: Alignment.center,
                    child: ListTile(
                      leading: CircleAvatar(
                          backgroundImage: NetworkImage(p.photoUrl)),
                      title: Text(p.name),
                    ),
                  )),
              if (isHost)
                ElevatedButton(
                  onPressed: () async {
                    final question =
                        await GameService().getRandomPrefieresQuestion();
                    await GameService().startGame(game.id, question);

                    // El resto de jugadores cambiarán automáticamente gracias al StreamBuilder
                    // El host también es redirigido por la lógica común
                  },
                  child: Text('Empezar partida'),
                ),
              ElevatedButton(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: widget.gameId));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Código copiado al portapapeles')),
                    );
                  },
                  child: Text("Copiar código"))
            ],
          ),
        );
      },
    );
  }
}
