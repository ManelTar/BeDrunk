import 'package:flutter/material.dart';

class MyPasswordTextfield extends StatefulWidget {
  // ignore: prefer_typing_uninitialized_variables
  final controller;
  final String hintText;
  final String labelText;

  const MyPasswordTextfield({
    super.key,
    required this.controller,
    required this.hintText,
    required this.labelText,
  });

  @override
  State<MyPasswordTextfield> createState() => _MyPasswordTextfieldState();
}

class _MyPasswordTextfieldState extends State<MyPasswordTextfield> {
  bool mostrarContrasena = true;

  void toogleContrasena() {
    setState(() {
      mostrarContrasena = !mostrarContrasena;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        // Agregar un padding horizontal de 20
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: TextField(
          controller: widget.controller,
          decoration: InputDecoration(
            hintText: widget.hintText,
            labelText: widget.labelText,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            suffixIcon: IconButton(
              icon: Icon(
                mostrarContrasena ? Icons.visibility : Icons.visibility_off,
              ),
              onPressed: toogleContrasena,
            ),
          ),
        ));
  }
}
