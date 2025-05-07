import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:proyecto_aa/models/juego.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<Juego>> _juegosFuture;

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
          jugadores: doc['Jugadores'],
          reglas: doc['Instrucciones'],
        );
      }).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> _refreshJuegos() async {
    setState(() {
      _juegosFuture = obtenerJuegos();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Page'),
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

                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 8,
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          juego.nombre,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Jugadores: ${juego.jugadores}",
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                        const SizedBox(height: 8),
                        Text(juego.reglas),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
