// IMPORTS IGUALES
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_drawer/flutter_advanced_drawer.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:proyecto_aa/components/my_card_picture.dart';
import 'package:proyecto_aa/components/my_drawer_picture.dart';
import 'package:proyecto_aa/components/my_profile_picture.dart';
import 'package:proyecto_aa/components/my_rateup_button.dart';
import 'package:proyecto_aa/models/juego.dart';
import 'package:proyecto_aa/screens/coleccion_page.dart';
import 'package:proyecto_aa/screens/help_page.dart';
import 'package:proyecto_aa/screens/legal_page.dart';

class FavPage extends StatefulWidget {
  const FavPage({super.key});

  @override
  State<FavPage> createState() => _FavPageState();
}

class _FavPageState extends State<FavPage> {
  final usuario = FirebaseAuth.instance.currentUser!.uid;
  late Future<List<Map<String, dynamic>>> _coleccionesFuture;
  final _advancedDrawerController = AdvancedDrawerController();
  String userName = "";

  @override
  void initState() {
    super.initState();
    _coleccionesFuture = _getColeccionesConJuegos();
    inicializarDatosUsuario();
  }

  Future<void> inicializarDatosUsuario() async {
    final username = await obtenerUsername();
    setState(() {
      userName = username ?? '';
    });
  }

  void cerrarSesion() async {
    await FirebaseAuth.instance.signOut();
  }

  // 🔁 Refrescar colecciones
  Future<void> _refreshColecciones() async {
    setState(() {
      _coleccionesFuture = _getColeccionesConJuegos();
    });
  }

  // 🔽 Obtener colecciones + juegos
  Future<List<Map<String, dynamic>>> _getColeccionesConJuegos() async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final coleccionesSnap = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('colecciones')
        .get();

    List<Map<String, dynamic>> resultado = [];

    for (var doc in coleccionesSnap.docs) {
      final data = doc.data();
      final nombre = data['nombre'];
      final juegosIds = List<String>.from(data['juegos'] ?? []);

      if (juegosIds.isEmpty) {
        resultado.add({'id': doc.id, 'nombre': nombre, 'juegos': []});
        continue;
      }

      final juegosSnap = await FirebaseFirestore.instance
          .collection('juegos')
          .where(FieldPath.documentId, whereIn: juegosIds)
          .get();

      final juegos = juegosSnap.docs.map((doc) {
        return Juego(
          nombre: doc.id,
          jugadoresMax: doc['JugadoresMax'],
          reglas: doc['Instrucciones'],
          descripcion: doc['Descripcion'],
          gif: doc['Gif'],
          foto: doc['foto'],
          jugable: doc['Jugable'] ?? false,
          tipo: doc['Tipo'] ?? '',
        );
      }).toList();

      resultado.add({
        'id': doc.id,
        'nombre': nombre,
        'juegos': juegos,
      });
    }

    return resultado;
  }

  @override
  Widget build(BuildContext context) {
    return AdvancedDrawer(
      backdropColor: Theme.of(context).colorScheme.surfaceContainerHigh,
      controller: _advancedDrawerController,
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
                MyDrawerPicture(
                  onTap: _handleMenuButtonPressed,
                ),
                const SizedBox(width: 12),
                const Text(
                  'Tus Colecciones',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(top: 10, right: 9),
              child: IconButton(
                icon: const Icon(
                  Icons.add,
                  size: 32,
                ),
                onPressed: () {
                  mostrarDialogoColecciones();
                },
              ),
            ),
          ],
        ),
        body: LiquidPullToRefresh(
          onRefresh: _refreshColecciones,
          animSpeedFactor: 3,
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: _coleccionesFuture,
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

              final colecciones = snapshot.data ?? [];

              if (colecciones.isEmpty) {
                return LiquidPullToRefresh(
                    onRefresh: _refreshColecciones,
                    animSpeedFactor: 3,
                    child: const Center(child: Text('No tienes colecciones.')));
              }

              return ListView.builder(
                itemCount: colecciones.length,
                padding: const EdgeInsets.all(14),
                itemBuilder: (context, index) {
                  final coleccion = colecciones[index];
                  final nombre = coleccion['nombre'];
                  final juegos =
                      (coleccion['juegos'] as List?)?.cast<Juego>() ?? [];

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      leading: MyCardPicture(coleccionId: coleccion['id']),
                      title: Text(nombre,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      subtitle: Text('${juegos.length} juego(s)'),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ColeccionDetallePage(
                              nombreColeccion: nombre,
                              juegos: juegos,
                              coleccionId: coleccion['id'],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  void _handleMenuButtonPressed() {
    _advancedDrawerController.showDrawer();
  }

  Future<void> mostrarDialogoColecciones() async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final coleccionesRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('colecciones');

    final snapshot = await coleccionesRef.get();
    final colecciones = snapshot.docs;

    String nombreNuevaColeccion = '';
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Nueva colección'),
          content: TextField(
            decoration: const InputDecoration(
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10))),
              hintText: 'Nombre de la colección',
            ),
            onChanged: (value) {
              nombreNuevaColeccion = value;
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                if (nombreNuevaColeccion.trim().isNotEmpty) {
                  await coleccionesRef.add({
                    'nombre': nombreNuevaColeccion.trim(),
                  });
                  Navigator.pop(context); // Cierra el diálogo de crear
                }
              },
              child: const Text('Crear'),
            ),
          ],
        );
      },
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
