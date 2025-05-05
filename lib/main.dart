import 'package:flutter/material.dart';
import 'package:proyecto_aa/screens/login_page.dart';
import 'package:proyecto_aa/screens/singin_page.dart';
import 'package:proyecto_aa/utils/my_themecode.dart';

void main() {
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
      home: const SinginPage(),
    );
  }
}
