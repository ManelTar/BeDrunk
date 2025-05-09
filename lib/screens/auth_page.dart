import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:proyecto_aa/screens/login_or_register.dart';
import 'package:proyecto_aa/screens/main_page.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return const Center(
                  child: Text('Error al cargar la autenticación'));
            } else if (snapshot.hasData) {
              return const MainPage(); // Usuario autenticado
            } else {
              return LoginOrRegisterPage(); // Usuario no autenticado
            }
          }),
    );
  }
}
