import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expansion_tile_card/expansion_tile_card.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_drawer/flutter_advanced_drawer.dart';
import 'package:giffy_dialog/giffy_dialog.dart' as giffy;
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:proyecto_aa/components/my_button_fav.dart';
import 'package:proyecto_aa/components/my_drawer_picture.dart';
import 'package:proyecto_aa/components/my_profile_picture.dart';
import 'package:proyecto_aa/components/my_search_textfield.dart';
import 'package:proyecto_aa/screens/fav_page.dart';
import 'package:proyecto_aa/models/juego.dart'; // Asegúrate de importar tu modelo

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _advancedDrawerController = AdvancedDrawerController();
  String nombreJuego = "";

  void cerrarSesion() async {
    await FirebaseAuth.instance.signOut();
  }

  void _handleMenuButtonPressed() {
    _advancedDrawerController.showDrawer();
  }

  @override
  Widget build(BuildContext context) {
    return AdvancedDrawer(
      backdropColor: Theme.of(context).colorScheme.surfaceContainerHigh,
      controller: _advancedDrawerController,
      animationCurve: Curves.easeInOut,
      animationDuration: const Duration(milliseconds: 300),
      animateChildDecoration: true,
      childDecoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      drawer: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const SizedBox(height: 24),
            const MyProfilePicture(),
            Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  FirebaseAuth.instance.currentUser!.displayName ?? 'Usuario',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Inicio'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.search),
              title: const Text('Buscar'),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SearchPage()),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.favorite),
              title: const Text('Favoritos'),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FavPage()),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Cerrar sesión'),
              onTap: cerrarSesion,
            ),
          ],
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Row(
              children: [
                MyDrawerPicture(onTap: _handleMenuButtonPressed),
                const SizedBox(width: 12),
                const Text(
                  'Búsqueda',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ),
        body: Column(
          children: [
            const SizedBox(height: 20),
            MySearchTextfield(
              onChanged: (value) {
                setState(() {
                  nombreJuego = value;
                });
              },
            ),
            const SizedBox(height: 15),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance.collection("juegos").snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: LoadingAnimationWidget.stretchedDots(
                        color: Theme.of(context).colorScheme.primary,
                        size: 75,
                      ),
                    );
                  }

                  final juegos = snapshot.data!.docs
                      .map((doc) => Juego.fromFirestore(doc))
                      .where((juego) =>
                          nombreJuego.isEmpty ||
                          juego.nombre
                              .toLowerCase()
                              .contains(nombreJuego.toLowerCase()))
                      .toList();

                  return ListView.builder(
                    itemCount: juegos.length,
                    itemBuilder: (context, index) {
                      final juego = juegos[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        child: ExpansionTileCard(
                          initialPadding: const EdgeInsets.only(bottom: 10),
                          finalPadding: const EdgeInsets.only(bottom: 10),
                          leading: const CircleAvatar(
                            backgroundColor: Colors.transparent,
                            child: Image(
                                image: AssetImage('lib/images/google.png')),
                          ),
                          initialElevation: 1,
                          elevation: 2,
                          title: Text(juego.nombre,
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(
                            'Jugadores: ${juego.jugadoresMax == -1 ? "" : "2"}${juego.jugadoresMax == -1 ? "" : "-"}${juego.jugadoresMax == -1 ? "Grupos" : juego.jugadoresMax}',
                            style: TextStyle(color: Colors.grey[700]),
                          ),
                          children: [
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
                              children: [
                                TextButton(
                                  onPressed: () {},
                                  child: const Column(
                                    children: [
                                      Icon(Icons.play_arrow_rounded),
                                      SizedBox(height: 2),
                                      Text('Jugar'),
                                    ],
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) =>
                                          giffy.GiffyDialog.image(
                                        Image.network(
                                          juego.gif,
                                          height: 200,
                                          fit: BoxFit.cover,
                                        ),
                                        title: Text(juego.nombre,
                                            textAlign: TextAlign.center),
                                        content: Text(juego.reglas,
                                            textAlign: TextAlign.center),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context),
                                            child: const Text('CANCEL'),
                                          ),
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context),
                                            child: const Text('OK'),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                  child: const Column(
                                    children: [
                                      Icon(Icons.info_rounded),
                                      SizedBox(height: 2),
                                      Text('Info'),
                                    ],
                                  ),
                                ),
                                BotonFavorito(nombreJuego: juego.nombre),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
