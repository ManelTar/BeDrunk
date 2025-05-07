import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:proyecto_aa/components/my_password_textfield.dart';
import 'package:proyecto_aa/components/my_squaretile.dart';
import 'package:proyecto_aa/components/my_textfield.dart';

class SinginPage extends StatefulWidget {
  final Function()? onTap;
  const SinginPage({super.key, required this.onTap});

  @override
  State<SinginPage> createState() => _SinginPageState();
}

class _SinginPageState extends State<SinginPage> {
  final userController = TextEditingController();
  final passController = TextEditingController();
  final confirmPassController = TextEditingController();

  void crearCuenta() async {
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
      //comprobar contraseñas
      if (passController.text == confirmPassController.text) {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: userController.text,
          password: passController.text,
        );
      } else {
        mostrarMensajeErrorContrasenas("Las contraseñas no coniciden");
      }
      Navigator.pop(context); // Solo si el login es exitoso
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context);
      print('Error al hacer login: ${e.code}');
      if (e.code == 'invalid-credential') {
        mostrarMensajeError("Email o contraseña incorrectos");
      }
    }
  }

  void mostrarMensajeErrorContrasenas(String mensaje) {
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
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
          child: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(
              height: 50,
            ),
            // Icono de la aplicación
            Center(
              child: Icon(
                Icons.person_2,
                size: 150,
              ),
            ),
            const SizedBox(
              height: 12,
            ),
            // Texto de bienvenida
            const Text(
              "¡Vamos a crear una cuenta!",
              style: TextStyle(
                fontSize: 14,
              ),
            ),
            const SizedBox(
              height: 50,
            ),
            // Input de usuario
            MyTextfield(
                hintText: '',
                controller: userController,
                labelText: 'Correo electrónico'),
            const SizedBox(
              height: 20,
            ),
            // Input de contraseña
            MyPasswordTextfield(
                hintText: 'Introduce tu contraseña',
                controller: passController,
                labelText: 'Contraseña'),
            const SizedBox(
              height: 20,
            ),
            MyPasswordTextfield(
                hintText: 'Vuelve a introducir tu contraseña',
                controller: passController,
                labelText: 'Contraseña'),
            const SizedBox(
              height: 15,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 26),
              child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                Text(
                  '¿Has olvidado la contraseña?',
                )
              ]),
            ),
            const SizedBox(
              height: 25,
            ),
            // Boton de login
            ElevatedButton(
              onPressed: crearCuenta,
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 60, vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: const Text(
                "Crear cuenta",
                style: TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            // Texto
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                      child: Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Divider(
                      thickness: 0.5,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  )),
                  Text(
                    'O continua con',
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface),
                  ),
                  Expanded(
                      child: Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Divider(
                      thickness: 0.5,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ))
                ],
              ),
            ),
            const SizedBox(height: 60),
            // Otras opciones de login
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SquareTile(onTap: () {}, imagePath: 'lib/images/google.png'),
                SizedBox(width: 15),
                SquareTile(onTap: () {}, imagePath: 'lib/images/apple.png'),
              ],
            ),
            const SizedBox(
              height: 60,
            ),
            // Crear sesión
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('¿Ya tienes una cuenta?'),
                SizedBox(width: 5),
                GestureDetector(
                  onTap: widget.onTap,
                  child: Text(
                    '¡Inicia sesión!',
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold),
                  ),
                )
              ],
            )
          ],
        ),
      )),
    );
  }
}
