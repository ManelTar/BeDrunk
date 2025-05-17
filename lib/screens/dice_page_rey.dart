import 'dart:math';
import 'package:flutter/material.dart';

class DicePageRey extends StatefulWidget {
  final String titulo;
  const DicePageRey({Key? key, required this.titulo}) : super(key: key);

  @override
  State<DicePageRey> createState() => _DicePageReyState();
}

class _DicePageReyState extends State<DicePageRey>
    with SingleTickerProviderStateMixin {
  int _diceNumber = 1;
  final _random = Random();

  late AnimationController _controller;
  late Animation<double> _animation;

  double _rotation = 0; // rotación actual
  String _mensaje = ""; // mensaje mostrado

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    );

    _animation = Tween<double>(begin: 0, end: 4 * pi).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    )..addListener(() {
        // Mientras anima, actualizamos la rotación
        setState(() => _rotation = _animation.value);
      });

    // Cuando la animación termina…
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        // 1️⃣  Deja la rotación exactamente en 0 rad (posición “natural”)
        setState(() => _rotation = 0);

        // 2️⃣  Cambia el número y mensaje cuando la imagen ya está en reposo
        final nuevo = _random.nextInt(6) + 1;
        setState(() {
          _diceNumber = nuevo;
          _mensaje = _getMensaje(nuevo);
        });

        // 3️⃣  Resetea el controller para la próxima tirada
        _controller.reset();
      }
    });
  }

  void _rollDice() => _controller.forward(from: 0);

  String _getMensaje(int numero) {
    switch (numero) {
      case 1:
        return 'Bebe el jugador de tu derecha';
      case 2:
        return 'Bebe el jugador de tu izquierda';
      case 3:
        return 'Bebe el rey del 3';
      case 4:
        return 'Bebes tú';
      case 5:
        return 'Bebe el jugador que tú quieras';
      case 6:
        return 'Bebéis todos';
      default:
        return '';
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildDice() {
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.001) // perspectiva 3D
        ..rotateY(_rotation),
      //..rotateZ(_rotation / 100), // giro sutil en Z
      child: Container(
        height: 200,
        width: 200,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
        child: Image.asset(
          'images/dice-$_diceNumber.png',
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.titulo,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700)),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildDice(),
            const SizedBox(height: 20),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              child: Text(
                _mensaje,
                key: ValueKey<String>(_mensaje),
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: _rollDice,
              icon: const Icon(Icons.casino),
              label: const Text("Lanzar"),
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                textStyle: const TextStyle(fontSize: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
