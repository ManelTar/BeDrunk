import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:proyecto_aa/screens/check_user_profile_page.dart';
import 'package:proyecto_aa/screens/login_or_register.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: LoadingAnimationWidget.stretchedDots(
                  color: Theme.of(context).colorScheme.primary, size: 75),
            );
          } else if (snapshot.hasError) {
            return const Center(
                child: Text('Error al cargar la autenticación'));
          } else if (snapshot.hasData) {
            return const CheckUserProfile(); // <-- Aquí rediriges según perfil
          } else {
            return const LoginOrRegisterPage();
          }
        },
      ),
    );
  }
}
