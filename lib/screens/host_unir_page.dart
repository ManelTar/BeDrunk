import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:proyecto_aa/models/player.dart';
import 'package:proyecto_aa/screens/lobby_page.dart';
import 'package:proyecto_aa/services/game_service.dart';
import 'package:proyecto_aa/services/storage_service.dart';

class HostUnirPage extends StatefulWidget {
  const HostUnirPage({super.key});

  @override
  State<HostUnirPage> createState() => _HostUnirPageState();
}

class _HostUnirPageState extends State<HostUnirPage> {
  StorageService storage = StorageService();
  final currentUser = FirebaseAuth.instance.currentUser!;
  String gameId = "";
  String userName = "";

  @override
  @override
  void initState() {
    super.initState();
    inicializarDatosUsuario();
  }

  Future<void> inicializarDatosUsuario() async {
    final username = await obtenerUsername();
    setState(() {
      userName = username ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surfaceTint,
      ),
      backgroundColor: Theme.of(context).colorScheme.surfaceTint,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () async {
                await hostearPartida();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (_) => LobbyPage(
                            gameId: gameId,
                          )),
                );
              },
              child: Card(
                elevation: 20,
                shadowColor:
                    Theme.of(context).colorScheme.surfaceContainerHighest,
                child: Padding(
                  padding: EdgeInsets.all(15),
                  child: Text(
                    "Crear una partida",
                    style: GoogleFonts.battambang(
                        textStyle: TextStyle(fontSize: 28)),
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: Card(
                elevation: 20,
                shadowColor:
                    Theme.of(context).colorScheme.surfaceContainerHighest,
                child: InkWell(
                  onTap: () async {
                    final enteredGameId = await showDialog<String>(
                      context: context,
                      builder: (context) {
                        String input = '';
                        return AlertDialog(
                          title: Text('Ingrese código de la partida'),
                          content: TextField(
                            keyboardType: TextInputType.number,
                            onChanged: (value) => input = value,
                            decoration:
                                InputDecoration(hintText: 'Código de juego'),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(null),
                              child: Text('Cancelar'),
                            ),
                            TextButton(
                              onPressed: () =>
                                  Navigator.of(context).pop(input.trim()),
                              child: Text('Unirse'),
                            ),
                          ],
                        );
                      },
                    );

                    if (enteredGameId == null || enteredGameId.isEmpty) {
                      // Usuario canceló o no ingresó nada
                      return;
                    }

                    final currentUser = FirebaseAuth.instance.currentUser!;
                    final photoUrl =
                        await getProfilePictureUrl(currentUser.uid) ?? '';
                    final player = Player(
                      uid: currentUser.uid,
                      name: userName,
                      photoUrl: photoUrl,
                    );

                    try {
                      await GameService().joinGame(enteredGameId, player);

                      // Navegar a la sala de juego
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => LobbyPage(gameId: enteredGameId),
                        ),
                      );
                    } catch (e) {
                      // Manejar error, por ejemplo mostrar SnackBar
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text('Error al unirse a la partida: $e')),
                      );
                    }
                  },
                  child: Padding(
                    padding: EdgeInsets.all(15),
                    child: Text(
                      "Unirse a una partida",
                      style: GoogleFonts.battambang(
                          textStyle: TextStyle(fontSize: 28)),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> hostearPartida() async {
    final photoUrl = await getProfilePictureUrl(currentUser.uid) ?? '';
    final hostPlayer =
        Player(uid: currentUser.uid, name: userName, photoUrl: photoUrl);

    gameId = await GameService().createGame(hostPlayer);
  }

  Future<String?> getProfilePictureUrl(String userId) async {
    try {
      final url = await storage.ref
          .child('profile_pictures/$userId.jpg')
          .getDownloadURL();
      return url;
    } catch (e) {
      print('Error al obtener URL de la imagen: $e');
      return null;
    }
  }

  Future<String?> obtenerUsername() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final doc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();

    if (doc.exists) {
      return doc.data()?['username'];
    }
    return null;
  }
}
