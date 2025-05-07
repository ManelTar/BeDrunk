import 'package:flutter/material.dart';
import 'package:proyecto_aa/screens/login_page.dart';
import 'package:proyecto_aa/screens/singin_page.dart';

class LoginOrRegisterPage extends StatefulWidget {
  const LoginOrRegisterPage({super.key});

  @override
  State<LoginOrRegisterPage> createState() => _LoginOrRegisterPageState();
}

class _LoginOrRegisterPageState extends State<LoginOrRegisterPage> {
  bool ensenarLogin = true; // true = login, false = register

  void cambiarPaginas() {
    setState(() {
      ensenarLogin = !ensenarLogin;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (ensenarLogin) {
      return LoginPage(
        onTap: cambiarPaginas,
      );
    } else {
      return SinginPage(
        onTap: cambiarPaginas,
      );
    }
  }
}
