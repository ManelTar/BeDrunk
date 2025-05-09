import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:proyecto_aa/models/juego.dart';
import 'package:proyecto_aa/services/fav_service.dart';
import 'package:expansion_tile_card/expansion_tile_card.dart';
import 'package:giffy_dialog/giffy_dialog.dart' as giffy;

class FavPage extends StatefulWidget {
  const FavPage({super.key});

  @override
  State<FavPage> createState() => _FavPageState();
}

class _FavPageState extends State<FavPage> {
  late Future<List<Juego>> _favJuegosFuture;

  @override
  void initState() {
    super.initState();
    _favJuegosFuture = _getFavJuegos();
  }

  void cerrarSesion() async {
    await FirebaseAuth.instance.signOut();
  }

  Future<List<Juego>> _getFavJuegos() async {
    List<String> nombres = await FavService().getFav();
    if (nombres.isEmpty) return [];

    final juegosSnapshot = await FirebaseFirestore.instance
        .collection('juegos')
        .where(FieldPath.documentId, whereIn: nombres)
        .get();

    return juegosSnapshot.docs.map((doc) {
      return Juego(
        nombre: doc.id,
        jugadoresMin: doc['JugadoresMin'],
        jugadoresMax: doc['JugadoresMax'],
        reglas: doc['Instrucciones'],
        descripcion: doc['Descripcion'],
        gif: doc['Gif'],
      );
    }).toList();
  }

  Future<void> _refreshJuegos() async {
    setState(() {
      _favJuegosFuture = _getFavJuegos();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favoritos'),
        actions: [
          IconButton(
            onPressed: cerrarSesion,
            icon: const Icon(Icons.logout),
          )
        ],
      ),
      body: LiquidPullToRefresh(
        onRefresh: _refreshJuegos,
        animSpeedFactor: 3,
        child: FutureBuilder<List<Juego>>(
          future: _favJuegosFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: LoadingAnimationWidget.stretchedDots(
                  color: Theme.of(context).colorScheme.primary,
                  size: 75,
                ),
              );
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            final juegos = snapshot.data ?? [];

            if (juegos.isEmpty) {
              return const Center(child: Text('No tienes juegos favoritos.'));
            }

            return ListView.builder(
              itemCount: juegos.length,
              padding: const EdgeInsets.all(14),
              itemBuilder: (context, index) {
                final juego = juegos[index];

                return ExpansionTileCard(
                  initialPadding: const EdgeInsets.only(bottom: 10),
                  finalPadding: const EdgeInsets.only(bottom: 10),
                  baseColor: Theme.of(context).colorScheme.surfaceContainerHigh,
                  leading: const CircleAvatar(
                    backgroundColor: Colors.transparent,
                    child: Icon(Icons.videogame_asset),
                  ),
                  elevation: 2,
                  title: Text(juego.nombre),
                  subtitle: Text(
                    'Jugadores: ${juego.jugadoresMin}${juego.jugadoresMax == -1 ? " " : "-"}${juego.jugadoresMax == -1 ? "o más" : juego.jugadoresMax}',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                  children: <Widget>[
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 8.0),
                        child: Text(
                          juego.descripcion,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium!
                              .copyWith(fontSize: 16),
                        ),
                      ),
                    ),
                    OverflowBar(
                      alignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        TextButton(
                          onPressed: () {},
                          child: const Column(
                            children: <Widget>[
                              Icon(Icons.play_arrow_rounded),
                              Padding(
                                padding: EdgeInsets.symmetric(vertical: 2.0),
                              ),
                              Text('Jugar'),
                            ],
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => giffy.GiffyDialog.image(
                                Image.network(
                                  juego.gif,
                                  height: 200,
                                  fit: BoxFit.cover,
                                ),
                                title: Text(
                                  juego.nombre,
                                  textAlign: TextAlign.center,
                                ),
                                content: Text(
                                  juego.reglas,
                                  textAlign: TextAlign.center,
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, 'CANCEL'),
                                    child: const Text('CANCEL'),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, 'OK'),
                                    child: const Text('OK'),
                                  ),
                                ],
                              ),
                            );
                          },
                          child: const Column(
                            children: <Widget>[
                              Icon(Icons.info_rounded),
                              Padding(
                                padding: EdgeInsets.symmetric(vertical: 2.0),
                              ),
                              Text('Info'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}
