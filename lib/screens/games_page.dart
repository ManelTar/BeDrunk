import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:proyecto_aa/models/player.dart';
import 'package:proyecto_aa/screens/dice_page.dart';
import 'package:proyecto_aa/screens/dice_page_rey.dart';
import 'package:proyecto_aa/screens/host_unir_page.dart';
import 'package:proyecto_aa/screens/lobby_page.dart';
import 'package:proyecto_aa/screens/names_page.dart';
import 'package:proyecto_aa/screens/reto_page.dart';
import 'package:proyecto_aa/services/game_service.dart';
import 'package:proyecto_aa/services/storage_service.dart';

class GamesPage extends StatefulWidget {
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
  State<GamesPage> createState() => _GamesPageState();
}

class _GamesPageState extends State<GamesPage> {
  @override
  Widget build(BuildContext context) {
    // Redirige tan pronto como se cargue la pantalla
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _irAJuego(context, widget.titulo);
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

  Future<void> _irAJuego(BuildContext context, String titulo) async {
    switch (titulo) {
      case 'Rey del 3':
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (_) => DicePageRey(
                    titulo: titulo,
                    gif: widget.gif,
                    reglas: widget.reglas,
                    mostrar: widget.mostrar,
                  )),
        );
        break;
      case 'Ruleta rusa':
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (_) => DicePage(
                    titulo: titulo,
                    gif: widget.gif,
                    reglas: widget.reglas,
                    mostrar: widget.mostrar,
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
      case 'Quien es más probable qué':
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => HostUnirPage()),
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
