import 'package:flutter/material.dart';

class MyTextfield extends StatelessWidget {
  final String hintText;
  final String labelText;
  final TextEditingController controller;
  const MyTextfield(
      {super.key,
      required this.hintText,
      required this.controller,
      required this.labelText});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hintText,
          labelText: labelText,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
      ),
    );
  }
}
