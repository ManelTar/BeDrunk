import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:proyecto_aa/components/my_changable_picture.dart';

class UserPage extends StatefulWidget {
  const UserPage({super.key});

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  final usuario = FirebaseAuth.instance.currentUser!.uid;
  String nuevoNombre =
      FirebaseAuth.instance.currentUser!.displayName.toString();
  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil de Usuario'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            MyChangablePicture(),
            const SizedBox(height: 20),
            TextField(
              decoration: const InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                hintText: 'Nombre de usuario',
              ),
              controller: TextEditingController(
                text: FirebaseAuth.instance.currentUser!.displayName ?? '',
              ),
              onChanged: (value) {
                nuevoNombre = value;
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: cambiarNombre, child: Text("Confirmar"))
          ],
        ),
      ),
    );
  }

  void cambiarNombre() async {
    try {
      await FirebaseAuth.instance.currentUser!
          .updateProfile(displayName: nuevoNombre);
      await FirebaseAuth.instance.currentUser!.reload();
      Navigator.of(context).pop();
      setState(() {});
    } catch (e) {
      print(e);
    }
  }
}
