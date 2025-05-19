import 'dart:math';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:proyecto_aa/models/preguntas.dart';
import 'package:giffy_dialog/giffy_dialog.dart' as giffy;

class RetoPage extends StatefulWidget {
  final String titulo;
  final String gif;
  final String reglas;
  final bool mostrar;
  const RetoPage(
      {Key? key,
      required this.titulo,
      required this.gif,
      required this.reglas,
      required this.mostrar})
      : super(key: key);

  @override
  State<RetoPage> createState() => _RetoPageState();
}

class _RetoPageState extends State<RetoPage> {
  final _random = Random();
  List<Preguntas> _retos = [];
  Preguntas? _retoActual;
  bool _loading = true;
  bool _started = false;

  static const colorizeColors = [
    Colors.purple,
    Colors.blue,
    Colors.yellow,
    Colors.red,
  ];

  static const colorizeTextStyle = TextStyle(fontSize: 50.0);

  List<String> _jugadores = [];
  int _turnoJugador = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_started) {
      _started = true;
      // Espera a que se complete el primer frame:
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _pedirJugadores();
      });
    }
  }

  // 1) Pedir lista de jugadores antes de cargar retos
  void _pedirJugadores() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        final controlador = TextEditingController();
        return AlertDialog(
          title: const Text('Añadir jugadores'),
          content: TextField(
            controller: controlador,
            decoration: const InputDecoration(
              hintText: 'Nombre de jugador',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                final nombre = controlador.text.trim();
                if (nombre.isNotEmpty) {
                  _jugadores.add(nombre);
                  Navigator.of(ctx).pop();
                  // volver a pedir otro o finalizar
                  _pedirJugadores();
                }
              },
              child: const Text('Añadir'),
            ),
            if (_jugadores.isNotEmpty)
              TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  _cargarRetos();
                },
                child: const Text('Hecho'),
              ),
          ],
        );
      },
    );
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
      appBar: AppBar(title: Text(widget.titulo)),
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
                  children: [
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
  Widget _buildAnimatedPregunta({required Key key}) {
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
          isRepeatingAnimation: false,
          totalRepeatCount: 1,
          animatedTexts: [
            ColorizeAnimatedText(
              '${_jugadores[_turnoJugador]}: ${_retoActual!.pregunta}',
              textStyle: colorizeTextStyle,
              colors: colorizeColors,
              speed: const Duration(milliseconds: 200),
            ),
          ],
        ),
      ),
    );
  }
}
