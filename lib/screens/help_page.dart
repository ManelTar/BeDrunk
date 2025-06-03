import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:proyecto_aa/screens/login_page.dart';
import 'package:proyecto_aa/screens/privacy_page.dart';
import 'package:proyecto_aa/screens/terms_page.dart';
import 'package:proyecto_aa/screens/themes_page.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  Future<void> _enviarCorreo(
      {required String asunto, required String cuerpo}) async {
    String? encodeQueryParameters(Map<String, String> params) {
      return params.entries
          .map((MapEntry<String, String> e) =>
              '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
          .join('&');
    }

    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'drunkinator.app@gmail.com',
      query: encodeQueryParameters({
        'subject': asunto,
        'body': cuerpo,
      }),
    );

    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      throw 'No se pudo abrir el cliente de correo.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Centro de soporte')),
      body: ListView(
        children: [
          const SizedBox(height: 10),
          Padding(
              padding: const EdgeInsets.only(left: 15),
              child: Text("Ayuda y comentarios",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Card(
              elevation: 20,
              shadowColor:
                  Theme.of(context).colorScheme.surfaceContainerHighest,
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.bug_report),
                    title: Text('Reportar un problema'),
                    onTap: () => _enviarCorreo(
                      asunto: 'Problema con la app',
                      cuerpo: 'Hola, encontré un problema en la aplicación:',
                    ),
                  ),
                  Padding(
                      padding: EdgeInsets.symmetric(horizontal: 15),
                      child: Divider()),
                  ListTile(
                    leading: Icon(Icons.lightbulb),
                    title: Text('Enviar juego o idea'),
                    onTap: () => _enviarCorreo(
                      asunto: 'Sugerencia de juego',
                      cuerpo:
                          '¡Hola! Tengo una idea de juego para Drunkinator:',
                    ),
                  ),
                  Padding(
                      padding: EdgeInsets.symmetric(horizontal: 15),
                      child: Divider()),
                  ListTile(
                    leading: Icon(Icons.comment),
                    title: Text('Enviar comentario'),
                    onTap: () => _enviarCorreo(
                      asunto: 'Feedback de usuario',
                      cuerpo:
                          'Me gustaría dejar el siguiente comentario sobre la app:',
                    ),
                  ),
                  Padding(
                      padding: EdgeInsets.symmetric(horizontal: 15),
                      child: Divider()),
                  ListTile(
                    leading: Icon(Icons.mail),
                    title: Text('Contactar con el equipo'),
                    onTap: () => _enviarCorreo(
                      asunto: 'Contacto general',
                      cuerpo:
                          'Hola equipo Drunkinator, quería comentarles que...',
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Padding(
              padding: const EdgeInsets.only(left: 15),
              child: Text(
                "Apóyame",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              )),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Card(
              elevation: 20,
              shadowColor:
                  Theme.of(context).colorScheme.surfaceContainerHighest,
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.coffee),
                    title: Text('¡Comprame un café!'),
                    onTap: () async {
                      final Uri url =
                          Uri.parse('https://buymeacoffee.com/maneltarazona');
                      if (await canLaunchUrl(url)) {
                        await launchUrl(url,
                            mode: LaunchMode.externalApplication);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('No se pudo abrir el enlace')),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
