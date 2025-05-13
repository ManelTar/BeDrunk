import 'package:flutter/material.dart';

class MySearchTextfield extends StatefulWidget {
  final Function(String)? onChanged;
  const MySearchTextfield({super.key, required this.onChanged});

  @override
  State<MySearchTextfield> createState() => _MySearchTextfieldState();
}

class _MySearchTextfieldState extends State<MySearchTextfield> {
  String juego = "";
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 15),
      child: TextField(
        decoration: InputDecoration(
            prefixIcon: Icon(Icons.search_rounded),
            hintText: "¿A qué quieres jugar?",
            hintStyle: TextStyle(fontWeight: FontWeight.bold),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(13)))),
        onChanged: widget.onChanged,
      ),
    );
  }
}
