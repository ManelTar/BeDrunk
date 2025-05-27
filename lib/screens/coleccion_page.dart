import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expansion_tile_card/expansion_tile_card.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:proyecto_aa/components/my_coleccion_picture.dart';
import 'package:proyecto_aa/models/juego.dart';
import 'package:giffy_dialog/giffy_dialog.dart' as giffy;
import 'package:proyecto_aa/services/fav_service.dart';

class ColeccionDetallePage extends StatefulWidget {
  final String coleccionId; // 👈 agrega esto
  final String nombreColeccion;
  final List<Juego> juegos;

  const ColeccionDetallePage({
    super.key,
    required this.nombreColeccion,
    required this.juegos,
    required this.coleccionId, // 👈 y aquí
  });

  @override
  State<ColeccionDetallePage> createState() => _ColeccionDetallePageState();
}

class _ColeccionDetallePageState extends State<ColeccionDetallePage> {
  String nombreColeccion = '';

  @override
  void initState() {
    super.initState();
    _refreshNombreColeccion();
  }

  Future<void> _refreshNombreColeccion() async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final docSnap = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('colecciones')
        .doc(widget.coleccionId)
        .get();

    if (docSnap.exists) {
      setState(() {
        nombreColeccion = docSnap.data()!['nombre'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    FavService favService = FavService();
    return Scaffold(
      appBar: AppBar(
        actions: [
          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(
                child: Text('Editar'),
                onTap: () {
                  mostrarDialogoActualizarColeccion(
                      widget.coleccionId, widget.nombreColeccion);
                },
              ),
              PopupMenuItem(
                child: Text('Eliminar'),
                onTap: () async {
                  await favService.removeColeccion(widget.coleccionId);
                  Navigator.pop(context, 'Eliminar');
                },
              ),
            ],
          ),
        ],
      ),
      body: widget.juegos.isEmpty
          ? const Center(child: Text('Esta colección no tiene juegos.'))
          : LiquidPullToRefresh(
              onRefresh: () async {
                // Aquí puedes agregar la lógica para refrescar la colección
                await _refreshNombreColeccion();
              },
              child: Column(children: [
                const SizedBox(height: 20),
                MyColeccionPicture(coleccionId: widget.coleccionId),
                const SizedBox(height: 10),
                Text(
                  widget.nombreColeccion,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: widget.juegos.length,
                    padding: const EdgeInsets.all(16),
                    itemBuilder: (context, index) {
                      final juego = widget.juegos[index];
                      return ExpansionTileCard(
                        initialPadding: const EdgeInsets.only(bottom: 10),
                        finalPadding: const EdgeInsets.only(bottom: 10),
                        baseColor:
                            Theme.of(context).colorScheme.surfaceContainerHigh,
                        elevation: 2,
                        title: Text(juego.nombre),
                        subtitle: Text(
                          'Jugadores: ${juego.jugadoresMax == -1 ? "" : "2"}${juego.jugadoresMax == -1 ? "" : "-"}${juego.jugadoresMax == -1 ? "Grupos" : juego.jugadoresMax}',
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
                                      padding:
                                          EdgeInsets.symmetric(vertical: 2.0),
                                    ),
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
                                      padding:
                                          EdgeInsets.symmetric(vertical: 2.0),
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
                  ),
                ),
              ]),
            ),
    );
  }

  Future<void> mostrarDialogoActualizarColeccion(
      String coleccionId, String nombreActual) async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final coleccionDocRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('colecciones')
        .doc(coleccionId);

    String nuevoNombre = nombreActual;

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Cambiar nombre de la colección'),
          content: TextField(
            decoration: const InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              hintText: 'Nuevo nombre de la colección',
            ),
            controller: TextEditingController(text: nombreActual),
            onChanged: (value) {
              nuevoNombre = value;
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                if (nuevoNombre.trim().isNotEmpty) {
                  await coleccionDocRef.update({
                    'nombre': nuevoNombre.trim(),
                  });
                  Navigator.pop(context); // Cierra el diálogo
                }
              },
              child: const Text('Actualizar'),
            ),
          ],
        );
      },
    );
  }
}
