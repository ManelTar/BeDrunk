import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:proyecto_aa/screens/dice_page.dart';
import 'package:proyecto_aa/screens/dice_page_rey.dart';

class GamesPage extends StatelessWidget {
  final String juego;
  final String titulo;

  const GamesPage({super.key, required this.juego, required this.titulo});

  @override
  Widget build(BuildContext context) {
    // Redirige tan pronto como se cargue la pantalla
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _irAJuego(context, juego);
    });

    return Scaffold(
      body: Center(
        child: LoadingAnimationWidget.stretchedDots(
          color: Theme.of(context).colorScheme.primary,
          size: 75,
        ), // pequeño loading mientras redirige
      ),
    );
  }

  void _irAJuego(BuildContext context, String juego) {
    switch (juego) {
      case 'dadosRey':
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => DicePageRey(titulo: titulo)),
        );
        break;
      case 'dados':
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => DicePage(titulo: titulo)),
        );
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Este juego aún no está disponible')),
        );
        Navigator.pop(context); // vuelve atrás si no hay pantalla válida
    }
  }
}
