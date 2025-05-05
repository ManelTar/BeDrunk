import 'package:flutter/material.dart';
import 'package:proyecto_aa/components/my_squaretile.dart';
import 'package:proyecto_aa/components/my_textfield.dart';

class SinginPage extends StatelessWidget {
  const SinginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController userController = TextEditingController();
    final TextEditingController passController = TextEditingController();
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
            MyTextfield(
                hintText: 'Introduce tu contraseña',
                controller: passController,
                labelText: 'Contraseña'),
            const SizedBox(
              height: 20,
            ),
            MyTextfield(
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
              onPressed: () {
                // Aquí puedes agregar la lógica de inicio de sesión
                // Por ejemplo, verificar las credenciales del usuario
                // y navegar a la página principal si son correctas.
              },
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
            const SizedBox(height: 50),
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
              height: 30,
            ),
            // Crear sesión
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('¿Ya tienes una cuenta?'),
                SizedBox(width: 5),
                GestureDetector(
                  // onTap: widget.onTap,
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
