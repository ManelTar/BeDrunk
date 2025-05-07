import 'package:flutter/material.dart';
import 'package:proyecto_aa/screens/auth_page.dart';
import 'package:proyecto_aa/utils/my_themecode.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:proyecto_aa/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Inicializa Firebase antes de ejecutar la aplicación
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Proyecto AA',
      theme: AppTheme.light, // Tema claro personalizado
      darkTheme: AppTheme.dark, // Tema oscuro personalizado
      themeMode: ThemeMode.system, // Usa el modo del sistema (puedes cambiarlo)
      home: const AuthPage(),
    );
  }
}
