import 'dart:math';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:proyecto_aa/models/preguntas.dart';

class RetoPage extends StatefulWidget {
  final List<String> jugadores;
  const RetoPage({super.key, required this.jugadores});

  @override
  State<RetoPage> createState() => _RetoPageState();
}

class _RetoPageState extends State<RetoPage> {
  final _random = Random();
  List<Preguntas> _retos = [];
  Preguntas? _retoActual;
  bool _loading = true;

  static const colorizeColors = [
    Colors.purple,
    Colors.blue,
    Colors.yellow,
    Colors.red,
  ];
  late final List<Color> colorizeNameColors;

  static const colorizeTextStyle = TextStyle(fontSize: 50.0);
  static var colorizeNameStyle =
      GoogleFonts.battambang(textStyle: TextStyle(fontSize: 75));

  late List<String> _jugadores = [];
  int _turnoJugador = 0;

  @override
  void initState() {
    super.initState();
    _jugadores = widget.jugadores;
    _cargarRetos();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    colorizeNameColors = [
      Theme.of(context).colorScheme.onSurface, // tu color dinámico
      Colors.purple,
      Colors.red,
      Colors.yellow,
      Colors.blue,
    ];
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
          .where((p) => p.tipo.toLowerCase() == 'reto')
          .toList();
    } catch (_) {
      _retos = [];
    }
    _siguienteReto();
    setState(() => _loading = false);
  }

  // 3) Elegir siguiente reto y avanzar turno de jugador
  void _siguienteReto() {
    if (_retos.isEmpty) {
      _retoActual = Preguntas(pregunta: 'No hay más retos.', tipo: 'reto');
    } else {
      _retoActual = _retos[_random.nextInt(_retos.length)];
    }
    // jugador actual en turno
    _turnoJugador = (_turnoJugador) % _jugadores.length;
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
      appBar: AppBar(title: Text("Cubata o Reto")),
      body: GestureDetector(
        onHorizontalDragEnd: _loading ? null : _onSwipe,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: _loading
              ? const CircularProgressIndicator()
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
      child: DefaultTextStyle(
        style: Theme.of(context)
            .textTheme
            .headlineMedium!
            .copyWith(color: Theme.of(context).colorScheme.onSurface),
        textAlign: TextAlign.center,
        child: AnimatedTextKit(
          pause: Duration(milliseconds: 0),
          isRepeatingAnimation: true,
          totalRepeatCount: 20,
          animatedTexts: [
            TypewriterAnimatedText(_jugadores[_turnoJugador],
                textStyle: colorizeNameStyle,
                speed: Duration(milliseconds: 100)),
            TypewriterAnimatedText(_jugadores[_turnoJugador],
                textStyle: colorizeNameStyle,
                speed: Duration(milliseconds: 100)),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedPregunta({required Key key}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10),
      child: Card(
        color: Colors.red,
        elevation: 15,
        key: key,
        child: DefaultTextStyle(
          style: Theme.of(context)
              .textTheme
              .headlineMedium!
              .copyWith(color: Theme.of(context).colorScheme.onSurface),
          textAlign: TextAlign.center,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 15),
            child: AnimatedTextKit(
              animatedTexts: [
                ColorizeAnimatedText(
                  _retoActual!.pregunta,
                  textStyle: colorizeTextStyle,
                  colors: colorizeColors,
                  speed: const Duration(milliseconds: 200),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
