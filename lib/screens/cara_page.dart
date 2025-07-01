import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:pretty_animated_text/pretty_animated_text.dart';
import 'package:proyecto_aa/models/preguntas.dart';

class CaraPage extends StatefulWidget {
  final List<String> jugadores;
  const CaraPage({super.key, required this.jugadores});

  @override
  State<CaraPage> createState() => _CaraPageState();
}

class _CaraPageState extends State<CaraPage> {
  final _random = Random();
  List<Preguntas> _retos = [];
  List<Preguntas> _retosDisponibles = [];
  Preguntas? _retoActual;
  bool _loading = true;

  static const colorizeTextStyle = TextStyle(fontSize: 40.0);

  late List<String> _jugadores = [];
  int _turnoJugador = 0;

  @override
  void initState() {
    super.initState();
    _jugadores = widget.jugadores;
    _cargarRetos();
  }

  // 2) Cargar retos desde Firestore (solo tipo "reto")
  Future<void> _cargarRetos() async {
    setState(() => _loading = true);
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('preguntas').get();
      _retos = snapshot.docs
          .map((doc) {
            final d = doc.data();
            return Preguntas(
              pregunta: d['pregunta'] ?? '',
              tipo: d['tipo'] ?? '',
            );
          })
          .where((p) => p.tipo.toLowerCase() == 'cara')
          .toList();

      // Copiar todos los retos a la lista disponible
      _retosDisponibles = List.from(_retos);
    } catch (_) {
      _retos = [];
      _retosDisponibles = [];
    }
    _siguienteReto();
    setState(() => _loading = false);
  }

  // 3) Elegir siguiente reto y avanzar turno de jugador
  void _siguienteReto() {
    if (_retosDisponibles.isEmpty) {
      // Reiniciar si ya se usaron todos
      _retosDisponibles = List.from(_retos);
    }

    if (_retosDisponibles.isEmpty) {
      _retoActual =
          Preguntas(pregunta: 'No hay más situaciones.', tipo: 'cara');
    } else {
      final index = _random.nextInt(_retosDisponibles.length);
      _retoActual = _retosDisponibles[index];
      _retosDisponibles.removeAt(index);
    }
  }

  // 4) Al tocar pantalla, actualizar reto y turno
  void _onSwipe(DragEndDetails details) {
    // opcional: comprueba dirección por details.primaryVelocity
    setState(() {
      _siguienteReto();
      _turnoJugador = (_turnoJugador + 1) % _jugadores.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onHorizontalDragEnd: _loading ? null : _onSwipe,
        child: Container(
          color: Theme.of(context).colorScheme.surfaceTint,
          width: double.infinity,
          height: double.infinity,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: _loading
              ? LoadingAnimationWidget.stretchedDots(
                  color: Theme.of(context).colorScheme.primary, size: 75)
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: _buildAnimatedJugador(
                        key: ValueKey(_retoActual), // aquí detecta cambio
                      ),
                    ),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: _buildAnimatedPregunta(
                        key: ValueKey(_retoActual), // aquí detecta cambio
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

// Esta función construye tu AnimatedTextKit envuelto en un widget con key
  Widget _buildAnimatedJugador({required Key key}) {
    return SizedBox(
      key: key,
      width: double.infinity,
      height: 80,
      child: DefaultTextStyle(
          style: Theme.of(context)
              .textTheme
              .headlineMedium!
              .copyWith(color: Theme.of(context).colorScheme.onSurface),
          textAlign: TextAlign.center,
          child: OffsetText(
            text: _jugadores[_turnoJugador],
            duration: Duration(milliseconds: 400),
            type: AnimationType.letter,
            textStyle:
                GoogleFonts.battambang(textStyle: TextStyle(fontSize: 75)),
          )),
    );
  }

  Widget _buildAnimatedPregunta({required Key key}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Card(
          elevation: 20,
          shadowColor: Theme.of(context).colorScheme.surfaceContainerHighest,
          key: key,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
            child: OffsetText(
              text: _retoActual!.pregunta,
              type: AnimationType.word,
              slideType: SlideAnimationType.bottomTop,
              duration: const Duration(milliseconds: 250),
              textStyle: colorizeTextStyle,
            ),
          )),
    );
  }
}
