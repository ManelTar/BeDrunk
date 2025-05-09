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
    if (isFavorito) {
      await FavService().removeFav(widget.nombreJuego);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Eliminado de favoritos")),
      );
    } else {
      FavService().saveFav(widget.nombreJuego);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Añadido a favoritos")),
      );
    }

    setState(() {
      isFavorito = !isFavorito;
    });
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
          Text('Guardar'),
        ],
      ),
    );
  }
}
