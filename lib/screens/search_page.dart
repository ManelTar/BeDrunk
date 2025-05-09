import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  void cerrarSesion() async {
    await FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buscar'),
        actions: [
          IconButton(
            onPressed: cerrarSesion,
            icon: const Icon(Icons.logout),
          )
        ],
      ),
      body: Center(
        child: Text('Página de búsqueda'),
      ),
    );
  }
}
