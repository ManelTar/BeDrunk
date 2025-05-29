import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:proyecto_aa/services/auth_service.dart';

class LoginPage extends StatefulWidget {
  final Function()? onTap;
  const LoginPage({super.key, required this.onTap});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final userController = TextEditingController();

  final passController = TextEditingController();

  Future<String?> iniciarSesion(LoginData data) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: data.name,
        password: data.password,
      );
      return null; // Login exitoso
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-credential') {
        return 'Email o contraseña incorrectos';
      }
      return 'Error inesperado: ${e.message}';
    }
  }

  Future<String?> crearCuenta(SignupData data) async {
    // Lógica para crear cuenta
    // Mostrar circulo de carga
    showDialog(
        context: context,
        builder: (context) {
          return Center(
            child: LoadingAnimationWidget.stretchedDots(
              color: Theme.of(context).colorScheme.primary,
              size: 75,
            ),
          );
        });

    try {
      //comprobar contraseñasif (passController.text == confirmPassController.text) {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: data.name.toString(),
        password: data.password.toString(),
      );

      Navigator.pop(context); // Solo si el login es exitoso
      return null; // Login exitoso
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context);
      if (e.code == 'invalid-credential') {
        mostrarMensajeError("Email o contraseña incorrectos");
      }
    }
    return null;
  }

  void mostrarMensajeError(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          mensaje,
          textAlign: TextAlign.center,
        ),
        duration: Duration(seconds: 2),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FlutterLogin(
        onLogin: iniciarSesion,
        onSignup: crearCuenta,
        onRecoverPassword: (String email) async {
          // Implementa aquí si quieres recuperación de contraseña
          try {
            await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
            mostrarMensajeError(
                "Se ha enviado un correo para recuperar la contraseña.");
          } on FirebaseAuthException catch (e) {
            if (e.code == 'user-not-found') {
              mostrarMensajeError("No se encontró una cuenta con ese email.");
            } else {
              mostrarMensajeError("Error al intentar recuperar la contraseña.");
            }
          }
          return null; // o devuelve un mensaje de error si aplica
        },
        logo: const AssetImage('lib/images/BeDrunk.png'),
        title: "Hola!",
        messages: LoginMessages(
          providersTitleFirst: 'O inicia sesión con',
          userHint: 'Email',
          passwordHint: 'Contraseña',
          confirmPasswordHint: 'Confirmar contraseña',
          loginButton: 'Iniciar sesión',
          signupButton: 'Crear cuenta',
          recoverPasswordButton: 'Recuperar contraseña',
          forgotPasswordButton: '¿Has olvidado tu contraseña?',
          recoverPasswordIntro:
              'Introduce tu email para recuperar tu contraseña',
          recoverPasswordDescription:
              'Te enviaremos un email con un enlace para recuperar tu contraseña',
        ),
        loginProviders: <LoginProvider>[
          LoginProvider(
            icon: FontAwesomeIcons.google,
            label: 'Google',
            callback: () async {
              debugPrint('start google sign in');
              AuthService().signInWithGoogle();
              debugPrint('stop google sign in');
              return null;
            },
          ),
        ],
      ),
    );
  }
}
