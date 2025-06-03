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
import 'package:proyecto_aa/components/my_rateup_button.dart';
import 'package:proyecto_aa/components/my_search_textfield.dart';
import 'package:proyecto_aa/screens/fav_page.dart';
import 'package:proyecto_aa/models/juego.dart';
import 'package:proyecto_aa/screens/games_page.dart';
import 'package:proyecto_aa/screens/help_page.dart';
import 'package:proyecto_aa/screens/legal_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final usuario = FirebaseAuth.instance.currentUser!.uid;
  final _advancedDrawerController = AdvancedDrawerController();
  String nombreJuego = "";
  List<String> recentSearches = [];
  String userName = "";

  @override
  void initState() {
    super.initState();
    loadRecentSearches();
    inicializarDatosUsuario();
  }

  Future<void> inicializarDatosUsuario() async {
    final username = await obtenerUsername();
    setState(() {
      userName = username ?? '';
    });
  }

  void loadRecentSearches() async {
    final searches = await getRecentSearches();
    setState(() {
      recentSearches = searches;
    });
  }

  void onSearch(String query) async {
    await saveSearch(query);
    loadRecentSearches();
    setState(() {
      nombreJuego = query;
    });
  }

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
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  const SizedBox(height: 24),
                  const MyProfilePicture(),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        userName,
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20),
                      ),
                    ),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.support_agent_rounded),
                    title: const Text('Centro de soporte'),
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const HelpPage())),
                  ),
                  ListTile(
                    leading: const Icon(Icons.policy_rounded),
                    title: const Text('Información legal'),
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const LegalPage())),
                  ),
                  RateAppButton()
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                tileColor: Theme.of(context).colorScheme.error,
                leading: Icon(
                  Icons.logout,
                  color: Theme.of(context).colorScheme.onError,
                ),
                title: Text(
                  'Cerrar sesión',
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.onError,
                      fontWeight: FontWeight.bold),
                ),
                onTap: cerrarSesion,
              ),
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
              onSubmitted: (value) {
                onSearch(value);
              },
            ),
            const SizedBox(height: 10),

            // Búsquedas recientes
            if (recentSearches.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text("Búsquedas recientes:",
                      style: Theme.of(context).textTheme.titleMedium),
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: recentSearches.map((query) {
                    return GestureDetector(
                      onTap: () => onSearch(query),
                      child: Chip(
                        backgroundColor:
                            Theme.of(context).colorScheme.surfaceTint,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        label: Text(query,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color:
                                    Theme.of(context).colorScheme.onSurface)),
                        deleteIcon: const Icon(Icons.close),
                        onDeleted: () => removeSearch(query),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: const Divider(),
              ),
              const SizedBox(height: 10),
            ],
            // Resultados
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance.collection("juegos").snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Center(
                        child: Text('Error al cargar los juegos'));
                  }

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
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    itemCount: juegos.length,
                    itemBuilder: (context, index) {
                      final juego = juegos[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: ExpansionTileCard(
                          initialPadding: const EdgeInsets.only(bottom: 10),
                          finalPadding: const EdgeInsets.only(bottom: 10),
                          initialElevation: 1,
                          elevation: 2,
                          title: Text(juego.nombre,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
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
                                if (juego.jugable)
                                  TextButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => GamesPage(
                                            juego: juego.tipo,
                                            titulo: juego.nombre,
                                            gif: juego.gif,
                                            reglas: juego.reglas,
                                            mostrar: true,
                                          ),
                                        ),
                                      );
                                    },
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
                                            child: const Text('CERRAR'),
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

  Future<void> saveSearch(String query) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> searches = prefs.getStringList('recent_searches') ?? [];

    searches.remove(query);
    searches.insert(0, query);

    if (searches.length > 10) {
      searches = searches.sublist(0, 10);
    }

    await prefs.setStringList('recent_searches', searches);
  }

  Future<List<String>> getRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('recent_searches') ?? [];
  }

  void removeSearch(String query) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> searches = prefs.getStringList('recent_searches') ?? [];

    searches.remove(query);
    await prefs.setStringList('recent_searches', searches);

    setState(() {
      recentSearches = searches;
    });
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
