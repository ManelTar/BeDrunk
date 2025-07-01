import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class FilterPage extends StatelessWidget {
  final String tipoJuego;

  const FilterPage({super.key, required this.tipoJuego});

  @override
  Widget build(BuildContext context) {
    // Redirige tan pronto como se cargue la pantalla
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _irAJuego(context, tipoJuego);
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
      case 'jugables':
        //Navigator.pushReplacement(
        //  context,
        //  MaterialPageRoute(builder: (_) => DicePageRey(titulo: titulo)),
        //);
        break;
      case 'dados':
        //Navigator.pushReplacement(
        //  context,
        //  MaterialPageRoute(builder: (_) => DicePageRey(titulo: titulo)),
        //);
        break;
      case 'cartas':
        //Navigator.pushReplacement(
        //  context,
        //  MaterialPageRoute(builder: (_) => DicePageRey(titulo: titulo)),
        //);
        break;
      case 'consola':
        //Navigator.pushReplacement(
        //  context,
        //  MaterialPageRoute(builder: (_) => DicePageRey(titulo: titulo)),
        //);
        break;
      case 'grupos':
        //Navigator.pushReplacement(
        //  context,
        //  MaterialPageRoute(builder: (_) => DicePageRey(titulo: titulo)),
        //);
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Este juego aún no está disponible')),
        );
        Navigator.pop(context); // vuelve atrás si no hay pantalla válida
    }
  }
}
