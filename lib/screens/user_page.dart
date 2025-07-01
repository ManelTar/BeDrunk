import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:proyecto_aa/components/my_changable_picture.dart';

class UserPage extends StatefulWidget {
  const UserPage({super.key});

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  String nuevoNombre = FirebaseAuth.instance.currentUser!.displayName ?? '';
  String nuevoUsername = '';

  final usuario = FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();
    inicializarDatosUsuario();
  }

  Future<void> inicializarDatosUsuario() async {
    final username = await obtenerUsername();
    setState(() {
      nuevoUsername = username ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil de Usuario'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              MyChangablePicture(),
              const SizedBox(height: 20),
              const SizedBox(height: 10),
              TextField(
                decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: 'Nombre',
                ),
                controller: TextEditingController(text: nuevoNombre),
                onChanged: (value) => nuevoNombre = value,
              ),
              const SizedBox(height: 20),
              const SizedBox(height: 10),
              TextField(
                decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: 'Nombre de usuario',
                ),
                controller: TextEditingController(text: nuevoUsername),
                onChanged: (value) => nuevoUsername = value.trim(),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                  onPressed: cambiarNombreYUsername, child: Text("Confirmar"))
            ],
          ),
        ),
      ),
    );
  }

  void cambiarNombreYUsername() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final userRef = FirebaseFirestore.instance.collection('users');

    if (nuevoUsername.isEmpty || nuevoNombre.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Rellena ambos campos')),
      );
      return;
    }

    // 1. Verifica que el nombre de usuario no esté ya en uso
    final existing =
        await userRef.where('username', isEqualTo: nuevoUsername).get();

    // 2. Si ya está en uso y no es el actual, cancela
    if (existing.docs.isNotEmpty && existing.docs.first.id != uid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ese nombre de usuario ya existe')),
      );
      return;
    }

    try {
      // 3. Actualiza displayName
      await FirebaseAuth.instance.currentUser!.updateDisplayName(nuevoNombre);
      await FirebaseAuth.instance.currentUser!.reload();

      // 4. Guarda el nombre de usuario en Firestore
      await userRef.doc(uid).set({
        'username': nuevoUsername,
        'nombre': nuevoNombre,
      }, SetOptions(merge: true));

      await FirebaseAuth.instance.currentUser!.reload();
      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al actualizar los datos')),
      );
    }
  }

  Future<String?> obtenerUsername() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final doc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();

    if (doc.exists) {
      return doc.data()?['username'];
    }
    return null;
  }
}
