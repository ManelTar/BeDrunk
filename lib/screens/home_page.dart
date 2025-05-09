import 'package:giffy_dialog/giffy_dialog.dart' as giffy;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expansion_tile_card/expansion_tile_card.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:proyecto_aa/components/my_button_fav.dart';
import 'package:proyecto_aa/components/my_drawer_picture.dart';
import 'package:proyecto_aa/components/my_profile_picture.dart';
import 'package:proyecto_aa/models/juego.dart';
import 'package:proyecto_aa/screens/fav_page.dart';
import 'package:proyecto_aa/screens/search_page.dart';
import 'package:proyecto_aa/services/fav_service.dart';
import 'package:stylish_bottom_bar/stylish_bottom_bar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<Juego>> _juegosFuture;
  int selected = 0;
  List<Widget> pages = [
    const HomePage(),
    const SearchPage(),
    const FavPage(),
  ];

  @override
  void initState() {
    super.initState();
    _juegosFuture = obtenerJuegos();
  }

  void cerrarSesion() async {
    await FirebaseAuth.instance.signOut();
  }

  Future<List<Juego>> obtenerJuegos() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('juegos').get();

      return snapshot.docs.map((doc) {
        return Juego(
          nombre: doc.id,
          jugadoresMin: doc['JugadoresMin'],
          jugadoresMax: doc['JugadoresMax'],
          reglas: doc['Instrucciones'],
          descripcion: doc['Descripcion'],
          gif: doc['Gif'],
        );
      }).toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Page'),
        leading: Builder(builder: (context) => MyDrawerPicture()
            //IconButton(
            //   icon: Icon(Icons.menu_book),
            //   onPressed: () => Scaffold.of(context).openDrawer(),
            // ),
            ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              child: SingleChildScrollView(
                child: Column(children: [
                  const MyProfilePicture(),
                  Text(FirebaseAuth.instance.currentUser!.displayName ??
                      'Usuario')
                ]),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Inicio'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.search),
              title: const Text('Buscar'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SearchPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.favorite),
              title: const Text('Favoritos'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const FavPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Cerrar sesión'),
              onTap: cerrarSesion,
            ),
          ],
        ),
      ),
      body: FutureBuilder<List<Juego>>(
        future: _juegosFuture,
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
            return const Center(child: Text('No hay juegos disponibles.'));
          }

          return ListView.builder(
            itemCount: juegos.length,
            padding: const EdgeInsets.all(14),
            itemBuilder: (context, index) {
              final juego = juegos[index];

              return ExpansionTileCard(
                initialPadding: EdgeInsets.only(bottom: 10),
                finalPadding: EdgeInsets.only(bottom: 10),
                baseColor: Theme.of(context).colorScheme.surfaceContainerHigh,
                leading: const CircleAvatar(
                    backgroundColor: Colors.transparent,
                    child: Image(image: AssetImage('lib/images/google.png'))),
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
                        horizontal: 16.0,
                        vertical: 8.0,
                      ),
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
                                  onPressed: () => Navigator.pop(context, 'OK'),
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
                      BotonFavorito(nombreJuego: juego.nombre),
                    ],
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
