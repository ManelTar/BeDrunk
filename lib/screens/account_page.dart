import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:proyecto_aa/screens/login_page.dart';
import 'package:proyecto_aa/screens/user_page.dart';
import 'package:proyecto_aa/services/storage_service.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});
  @override
  Widget build(BuildContext context) {
    final storageService = StorageService();
    final usuario = FirebaseAuth.instance.currentUser!.uid;
    return Scaffold(
      appBar: AppBar(
        title: Text("Ajustes"),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 10),
          Padding(
              padding: const EdgeInsets.only(left: 15),
              child: Text(
                "Cuenta",
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
                    leading: Icon(Icons.person),
                    title: Text('Editar perfil'),
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (_) => UserPage()));
                    },
                  ),
                  Padding(
                      padding: EdgeInsets.symmetric(horizontal: 15),
                      child: Divider()),
                  ListTile(
                    leading: Icon(Icons.person_off),
                    title: Text('Eliminar foto de perfil'),
                    onTap: () async {
                      await storageService
                          .deleteFile('profile_pictures/$usuario.jpg');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(
                                'Foto de perfil eliminada correctamente.')),
                      );
                    },
                  ),
                  Padding(
                      padding: EdgeInsets.symmetric(horizontal: 15),
                      child: Divider()),
                  ListTile(
                    leading: Icon(Icons.delete_forever),
                    title: Text('Eliminar cuenta'),
                    onTap: () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text('¿Eliminar cuenta?'),
                          content: Text(
                              'Esta acción es irreversible. ¿Estás seguro?'),
                          actions: [
                            TextButton(
                              style: TextButton.styleFrom(
                                backgroundColor:
                                    Theme.of(context).colorScheme.error,
                                foregroundColor:
                                    Theme.of(context).colorScheme.onError,
                              ),
                              child: Text('Cancelar'),
                              onPressed: () => Navigator.of(context).pop(false),
                            ),
                            TextButton(
                              child: Text('Eliminar'),
                              onPressed: () => Navigator.of(context).pop(true),
                            ),
                          ],
                        ),
                      );

                      if (confirmed == true) {
                        try {
                          await FirebaseAuth.instance.currentUser?.delete();
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => LoginPage(onTap: () {})));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content:
                                    Text('Cuenta eliminada correctamente.')),
                          );
                          // Puedes redirigir al usuario al login o salir de la app
                        } on FirebaseAuthException catch (e) {
                          if (e.code == 'requires-recent-login') {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(
                                      'Necesitas volver a iniciar sesión para eliminar tu cuenta.')),
                            );
                            // Aquí podrías redirigir al flujo de login para reautenticar
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(
                                      'Error al eliminar cuenta: ${e.message}')),
                            );
                          }
                        }
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
