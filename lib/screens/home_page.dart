import 'package:flutter_advanced_drawer/flutter_advanced_drawer.dart';
import 'package:giffy_dialog/giffy_dialog.dart' as giffy;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expansion_tile_card/expansion_tile_card.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_aa/components/ad_helper.dart';
import 'package:proyecto_aa/components/my_button_fav.dart';
import 'package:proyecto_aa/components/my_drawer_picture.dart';
import 'package:proyecto_aa/components/my_home_card.dart';
import 'package:proyecto_aa/components/my_profile_picture.dart';
import 'package:proyecto_aa/components/my_rateup_button.dart';
import 'package:proyecto_aa/models/juego.dart';
import 'package:proyecto_aa/models/user_data_notifier.dart';
import 'package:proyecto_aa/screens/games_page.dart';
import 'package:proyecto_aa/screens/legal_page.dart';
import 'package:proyecto_aa/screens/settings_page.dart';
import 'package:proyecto_aa/screens/stats_page.dart';
import 'package:proyecto_aa/services/games_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final usuario = FirebaseAuth.instance.currentUser!.uid;
  late Future<List<Juego>> _juegosFuture;
  final _advancedDrawerController = AdvancedDrawerController();
  String userName = "";

  String? _categoriaSeleccionada;

  @override
  void initState() {
    super.initState();
    _juegosFuture = obtenerJuegos();
    inicializarDatosUsuario();
  }

  Future<void> inicializarDatosUsuario() async {
    final username = await obtenerUsername();
    setState(() {
      userName = username ?? '';
    });
  }

  Future<List<Juego>> obtenerJuegos() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('juegos').get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Juego(
          nombre: doc.id,
          jugadoresMax: data['JugadoresMax'],
          descripcion: data['Descripcion'],
          gif: data['Gif'],
          foto: data['foto'],
          reglas: data['Instrucciones'],
          jugable: data['Jugable'] ?? false,
          tipo: data['Tipo'] ?? '',
        );
      }).toList();
    } catch (_) {
      return [];
    }
  }

  void cerrarSesion() => FirebaseAuth.instance.signOut();
  @override
  Widget build(BuildContext context) {
    final userData = Provider.of<UserDataNotifier>(context);
    final categorias = ["Jugable", "Grupos", "Dados", "Cartas", "Consolas"];

    return AdvancedDrawer(
      backdropColor: Theme.of(context).colorScheme.surfaceContainerHigh,
      controller: _advancedDrawerController,
      animationCurve: Curves.easeInOut,
      animationDuration: const Duration(milliseconds: 300),
      animateChildDecoration: true,
      childDecoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(16))),
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
                    leading: const Icon(Icons.settings),
                    title: const Text('Ajustes'),
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const SettingsPage())),
                  ),
                  ListTile(
                    leading: const Icon(Icons.policy_rounded),
                    title: const Text('Información legal'),
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const LegalPage())),
                  ),
                  ListTile(
                    leading: const Icon(Icons.bar_chart_sharp),
                    title: const Text('Estadísticas'),
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const StatsPage())),
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
                MyDrawerPicture(onTap: () {
                  _advancedDrawerController.showDrawer();
                }),
                const SizedBox(width: 12),
                const Text('Inicio',
                    style:
                        TextStyle(fontSize: 28, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.only(top: 10),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // --- CATEGORÍAS ---
            Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: Text("Categorías",
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.w700)),
            ),
            const SizedBox(height: 15),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  children: [
                    if (_categoriaSeleccionada != null)
                      MyHomeCard(
                        nombreCard: "Quitar filtro",
                        isSelected: false,
                        onTap: () =>
                            setState(() => _categoriaSeleccionada = null),
                      ),
                    for (final cat in categorias)
                      MyHomeCard(
                        nombreCard: cat,
                        isSelected: _categoriaSeleccionada == cat,
                        onTap: () =>
                            setState(() => _categoriaSeleccionada = cat),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // --- DESTACADO ---
            Padding(
              padding: const EdgeInsets.only(left: 16.0, bottom: 8),
              child: Text("Destacado",
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall!
                      .copyWith(fontWeight: FontWeight.bold)),
            ),
            FutureBuilder<Juego?>(
              future: obtenerJuegoDelDia(),
              builder: (context, snapDest) {
                if (!snapDest.hasData) {
                  return Center(
                    child: LoadingAnimationWidget.stretchedDots(
                        color: Theme.of(context).colorScheme.primary, size: 75),
                  );
                }
                final juego = snapDest.data!;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Stack(children: [
                      Container(
                        height: MediaQuery.of(context).size.height * 0.28,
                        width: double.infinity,
                        decoration: BoxDecoration(
                            image: DecorationImage(
                                image: NetworkImage(juego.foto),
                                fit: BoxFit.cover)),
                      ),
                      Positioned.fill(
                          child:
                              Container(color: Colors.black.withOpacity(0.4))),
                      Positioned(
                        left: 20,
                        bottom: 20,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(juego.nombre,
                                style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white)),
                            const SizedBox(height: 8),
                            ElevatedButton.icon(
                              onPressed: () {
                                if (juego.jugable) {
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
                                } else {
                                  showDialog(
                                    context: context,
                                    builder: (_) => giffy.GiffyDialog.image(
                                      Image.network(juego.gif,
                                          height: 200, fit: BoxFit.cover),
                                      title: Text(juego.nombre,
                                          textAlign: TextAlign.center),
                                      content: SingleChildScrollView(
                                        child: Text(juego.reglas,
                                            textAlign: TextAlign.center),
                                      ),
                                      actions: [
                                        TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context),
                                            child: const Text('OK')),
                                      ],
                                    ),
                                  );
                                }
                              },
                              icon: Icon(
                                juego.jugable
                                    ? Icons.play_arrow_rounded
                                    : Icons.info,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                              label: Text(juego.jugable ? "Jugar" : "Info"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    Theme.of(context).colorScheme.surfaceTint,
                                foregroundColor:
                                    Theme.of(context).colorScheme.onSurface,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                            )
                          ],
                        ),
                      )
                    ]),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),

            // --- TODOS LOS JUEGOS ---
            Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: Text("Todos los juegos",
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.w700)),
            ),
            const SizedBox(height: 5),
            FutureBuilder<List<Juego>>(
              future: _juegosFuture,
              builder: (context, snapAll) {
                if (snapAll.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: LoadingAnimationWidget.stretchedDots(
                        color: Theme.of(context).colorScheme.primary, size: 75),
                  );
                }
                if (snapAll.hasError) {
                  return Center(child: Text('Error: ${snapAll.error}'));
                }
                final juegos = snapAll.data ?? [];
                final juegosFiltrados = _categoriaSeleccionada == null
                    ? juegos
                    : juegos.where((j) {
                        if (_categoriaSeleccionada == "Jugable")
                          return j.jugable;
                        return j.tipo == _categoriaSeleccionada;
                      }).toList();

                if (juegosFiltrados.isEmpty) {
                  return const Center(
                      child:
                          Text('No hay juegos disponibles en esta categoría.'));
                }

                return SizedBox(
                  height: MediaQuery.of(context).size.height * 0.7,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(14),
                    itemCount: juegosFiltrados.length,
                    itemBuilder: (context, i) {
                      final juego = juegosFiltrados[i];
                      return ExpansionTileCard(
                        animateTrailing: true,
                        initialPadding: const EdgeInsets.only(bottom: 10),
                        finalPadding: const EdgeInsets.only(bottom: 10),
                        initialElevation: 0.1,
                        elevation: 2,
                        title: Text(juego.nombre,
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(
                          'Jugadores: ${juego.jugadoresMax == -1 ? "" : "2"}${juego.jugadoresMax == -1 ? "" : "-"}${juego.jugadoresMax == -1 ? "Grupos" : juego.jugadoresMax}',
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 8.0),
                            child: Text(juego.descripcion,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .copyWith(fontSize: 16)),
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
                                    builder: (_) => giffy.GiffyDialog.image(
                                      Image.network(juego.gif,
                                          height: 200, fit: BoxFit.cover),
                                      title: Text(juego.nombre,
                                          textAlign: TextAlign.center),
                                      content: SingleChildScrollView(
                                        child: Text(juego.reglas,
                                            textAlign: TextAlign.center),
                                      ),
                                      actions: [
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
                                            child: const Text('JUGAR'),
                                          ),
                                        TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context),
                                            child: const Text('OK')),
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
                          )
                        ],
                      );
                    },
                  ),
                );
              },
            ),
          ]),
        ),
      ),
    );
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
