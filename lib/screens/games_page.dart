import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:proyecto_aa/screens/dice_page.dart';
import 'package:proyecto_aa/screens/dice_page_rey.dart';
import 'package:proyecto_aa/screens/names_page.dart';
import 'package:proyecto_aa/screens/reto_page.dart';

class GamesPage extends StatelessWidget {
  final String juego;
  final String titulo;
  final String gif;
  final String reglas;
  final bool mostrar;

  const GamesPage(
      {super.key,
      required this.juego,
      required this.titulo,
      required this.gif,
      required this.reglas,
      required this.mostrar});

  @override
  Widget build(BuildContext context) {
    // Redirige tan pronto como se cargue la pantalla
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _irAJuego(context, titulo);
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

  void _irAJuego(BuildContext context, String titulo) {
    switch (titulo) {
      case 'Rey del 3':
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (_) => DicePageRey(
                    titulo: titulo,
                    gif: gif,
                    reglas: reglas,
                    mostrar: mostrar,
                  )),
        );
        break;
      case 'Ruleta rusa':
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (_) => DicePage(
                    titulo: titulo,
                    gif: gif,
                    reglas: reglas,
                    mostrar: mostrar,
                  )),
        );
        break;
      case 'Cubata o Reto':
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (_) => NamesPage(
                    titulo: titulo,
                  )),
        );
        break;
      case 'Cubata o Verdad':
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (_) => NamesPage(
                    titulo: titulo,
                  )),
        );
        break;
      case 'Que cara pondrías si':
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (_) => NamesPage(
                    titulo: titulo,
                  )),
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
