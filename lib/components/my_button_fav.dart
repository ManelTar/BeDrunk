import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:proyecto_aa/services/fav_service.dart';

class BotonFavorito extends StatefulWidget {
  final String nombreJuego;
  const BotonFavorito({super.key, required this.nombreJuego});

  @override
  State<BotonFavorito> createState() => _BotonFavoritoState();
}

class _BotonFavoritoState extends State<BotonFavorito> {
  bool isFavorito = false;

  @override
  void initState() {
    super.initState();
    verificarFavorito();
  }

  void verificarFavorito() async {
    final favs = await FavService().getFav();
    setState(() {
      isFavorito = favs.contains(widget.nombreJuego);
    });
  }

  void toggleFavorito() async {
    await mostrarDialogoColecciones(context, widget.nombreJuego);
    verificarFavorito(); // Refresca el icono después del diálogo
  }

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: toggleFavorito,
      child: Column(
        children: [
          Icon(
            isFavorito ? Icons.favorite : Icons.favorite_border,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 2),
          const Text('Guardar'),
        ],
      ),
    );
  }
}

Future<void> _mostrarDialogoNuevaColeccion(
  BuildContext context,
  CollectionReference coleccionesRef,
  String juegoId,
) async {
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
                  'juegos': [juegoId],
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Crear'),
          ),
        ],
      );
    },
  );
}

Future<void> mostrarDialogoColecciones(
    BuildContext context, String juegoId) async {
  final userId = FirebaseAuth.instance.currentUser!.uid;
  final coleccionesRef = FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .collection('colecciones');

  List<QueryDocumentSnapshot> colecciones = (await coleccionesRef.get()).docs;

  await showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Guardar en colecciones'),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView(
                shrinkWrap: true,
                children: [
                  ...colecciones.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final nombre = data['nombre'] as String;
                    List<String> juegos =
                        List<String>.from(data['juegos'] ?? []);
                    final contieneJuego = juegos.contains(juegoId);

                    return CheckboxListTile(
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: -20),
                      checkboxShape: const CircleBorder(),
                      checkboxScaleFactor: 1.05,
                      title: Text(
                        nombre,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      value: contieneJuego,
                      onChanged: (value) async {
                        final docRef = coleccionesRef.doc(doc.id);

                        if (value == true) {
                          if (!juegos.contains(juegoId)) {
                            juegos.add(juegoId);
                            await docRef.update({'juegos': juegos});
                          }
                        } else {
                          juegos.remove(juegoId);
                          await docRef.update({'juegos': juegos});
                        }

                        // Volver a obtener las colecciones actualizadas
                        colecciones = (await coleccionesRef.get()).docs;
                        setState(() {}); // Refresca el checkbox
                      },
                    );
                  }).toList(),
                  const Divider(),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('Crear nueva colección'),
                    onPressed: () async {
                      await _mostrarDialogoNuevaColeccion(
                          context, coleccionesRef, juegoId);
                      colecciones = (await coleccionesRef.get()).docs;
                      setState(() {}); // Refresca la lista
                    },
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}
