import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:proyecto_aa/models/game.dart';
import 'package:proyecto_aa/models/player.dart';

class ResultadoFinalPage extends StatefulWidget {
  final String gameId;

  const ResultadoFinalPage({super.key, required this.gameId});

  @override
  State<ResultadoFinalPage> createState() => _ResultadoFinalPageState();
}

class _ResultadoFinalPageState extends State<ResultadoFinalPage>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.3), // empieza desde abajo
      end: Offset.zero, // termina en su posición natural
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _controller.forward(); // inicia la animación
  }

  @override
  void dispose() {
    _controller.dispose(); // evita pérdidas de memoria
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gameRef =
        FirebaseFirestore.instance.collection('games').doc(widget.gameId);

    return FutureBuilder<DocumentSnapshot>(
      future: gameRef.get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final game = Game.fromFirestore(snapshot.data!);
        final most = game.players.firstWhere(
          (p) => p.uid == game.mostVotedUid,
          orElse: () => Player(uid: '', name: 'Desconocido', photoUrl: ''),
        );
        final least = game.players.firstWhere(
          (p) => p.uid == game.leastVotedUid,
          orElse: () => Player(uid: '', name: 'Desconocido', photoUrl: ''),
        );

        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surfaceTint,
          appBar: AppBar(
            title: Text('Resultado Final'),
            backgroundColor: Theme.of(context).colorScheme.surfaceTint,
          ),
          body: Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Más votado",
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  _buildResultCard(most),
                  SizedBox(height: 40),
                  Text(
                    "Menos votado",
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  _buildResultCard(least),
                  SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.popUntil(context, (route) => route.isFirst);
                    },
                    child: Text('Volver al inicio'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildResultCard(Player player) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Card(
          color: Theme.of(context).colorScheme.surface,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 30),
            child: Column(
              children: [
                SizedBox(height: 10),
                CircleAvatar(
                  radius: 50,
                  backgroundImage: player.photoUrl.isNotEmpty
                      ? NetworkImage(player.photoUrl)
                      : null,
                  child: player.photoUrl.isEmpty
                      ? Icon(Icons.person, size: 40)
                      : null,
                ),
                SizedBox(height: 10),
                Text(
                  player.name,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
