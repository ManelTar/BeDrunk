import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:pretty_animated_text/pretty_animated_text.dart';
import 'package:proyecto_aa/models/preguntas.dart';

class RetoPage extends StatefulWidget {
  final List<String> jugadores;
  const RetoPage({super.key, required this.jugadores});

  @override
  State<RetoPage> createState() => _RetoPageState();
}

enum SwipeDirection { left, right }

class _RetoPageState extends State<RetoPage> {
  final _random = Random();
  List<Preguntas> _retos = [];
  List<Preguntas> _retosDisponibles = [];
  Preguntas? _retoActual;
  bool _loading = true;

  static var colorizeTextStyle =
      GoogleFonts.battambang(textStyle: TextStyle(fontSize: 40));

  late List<String> _jugadores = [];
  int _turnoJugador = 0;

  SwipeDirection _lastSwipeDirection = SwipeDirection.right;

  @override
  void initState() {
    super.initState();
    _jugadores = widget.jugadores;
    _cargarRetos();
  }

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
          .where((p) => p.tipo.toLowerCase() == 'reto')
          .toList();

      _retosDisponibles = List.from(_retos);
    } catch (_) {
      _retos = [];
      _retosDisponibles = [];
    }
    _siguienteReto();
    setState(() => _loading = false);
  }

  void _siguienteReto() {
    if (_retosDisponibles.isEmpty) {
      _retosDisponibles = List.from(_retos);
    }

    if (_retosDisponibles.isEmpty) {
      _retoActual = Preguntas(pregunta: 'No hay más retos.', tipo: 'reto');
    } else {
      final index = _random.nextInt(_retosDisponibles.length);
      _retoActual = _retosDisponibles[index];
      _retosDisponibles.removeAt(index);
    }
  }

  void _onSwipe(DragEndDetails details) {
    if (details.primaryVelocity != null) {
      setState(() {
        _lastSwipeDirection = details.primaryVelocity! < 0
            ? SwipeDirection.left
            : SwipeDirection.right;
        _siguienteReto();
        _turnoJugador = (_turnoJugador + 1) % _jugadores.length;
      });
    }
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
                        key: ValueKey(_retoActual),
                      ),
                    ),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder:
                          (Widget child, Animation<double> animation) {
                        final offset =
                            _lastSwipeDirection == SwipeDirection.left
                                ? const Offset(1.0, 0.0)
                                : const Offset(-1.0, 0.0);
                        return SlideTransition(
                          position: Tween<Offset>(
                            begin: offset,
                            end: Offset.zero,
                          ).animate(animation),
                          child: child,
                        );
                      },
                      child: _buildAnimatedPregunta(
                        key: ValueKey(_retoActual?.pregunta),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

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
          textStyle: GoogleFonts.battambang(textStyle: TextStyle(fontSize: 75)),
        ),
      ),
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
        ),
      ),
    );
  }
}
