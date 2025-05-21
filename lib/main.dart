import 'package:cloud_firestore/cloud_firestore.dart';
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

  final firestore = FirebaseFirestore.instance;

  final preguntas = [
    {
      'pregunta':
          'Qué cara pondrías si vas a saludar a alguien y no era para ti el saludo.',
      'tipo': 'cara'
    },
    {
      'pregunta':
          'Qué cara pondrías si te toca leer en voz alta y no sabes pronunciar una palabra.',
      'tipo': 'cara'
    },
    {
      'pregunta':
          'Qué cara pondrías si ves un mensaje hot de tu madre/padre sin querer.',
      'tipo': 'cara'
    },
    {
      'pregunta':
          'Qué cara pondrías si alguien te grita por la calle “¡oye tú, guapo/a!”.',
      'tipo': 'cara'
    },
    {
      'pregunta':
          'Qué cara pondrías si alguien se tira un pedo en tu cara sin querer.',
      'tipo': 'cara'
    },
    {
      'pregunta': 'Qué cara pondrías si se te cae el móvil en el váter.',
      'tipo': 'cara'
    },
    {
      'pregunta':
          'Qué cara pondrías si te toca hacer una videollamada justo después de llorar.',
      'tipo': 'cara'
    },
    {
      'pregunta':
          'Qué cara pondrías si tu crush ve una foto tuya muy antigua y ridícula.',
      'tipo': 'cara'
    },
    {
      'pregunta':
          'Qué cara pondrías si tienes que entrar a clase o al trabajo después de una noche de fiesta intensa.',
      'tipo': 'cara'
    },
    {
      'pregunta':
          'Qué cara pondrías si entras en un lugar y todos se quedan callados y te miran.',
      'tipo': 'cara'
    },
    {
      'pregunta':
          'Qué cara pondrías si tu madre empieza a seguirte en todas tus redes sociales.',
      'tipo': 'cara'
    },
    {
      'pregunta':
          'Qué cara pondrías si vas a besar a alguien y te dice “no, mejor amigos”.',
      'tipo': 'cara'
    },
    {
      'pregunta':
          'Qué cara pondrías si te llaman por megafonía en el supermercado por algo embarazoso.',
      'tipo': 'cara'
    },
    {
      'pregunta':
          'Qué cara pondrías si abres una nota de voz delante de todos y es algo íntimo.',
      'tipo': 'cara'
    },
    {
      'pregunta':
          'Qué cara pondrías si ves a tu ex con su nueva pareja en el mismo bar que tú.',
      'tipo': 'cara'
    },
    {
      'pregunta':
          'Qué cara pondrías si alguien empieza a llorar frente a ti y no sabes qué hacer.',
      'tipo': 'cara'
    },
    {
      'pregunta':
          'Qué cara pondrías si te pillan diciendo algo malo sobre alguien que tienes justo detrás.',
      'tipo': 'cara'
    },
    {
      'pregunta':
          'Qué cara pondrías si estás hablando mal de alguien por mensaje y se lo mandas por error.',
      'tipo': 'cara'
    },
    {
      'pregunta':
          'Qué cara pondrías si ves un vídeo tuyo haciendo el ridículo viral en redes.',
      'tipo': 'cara'
    },
    {
      'pregunta':
          'Qué cara pondrías si confundes a un desconocido con tu amigo y le hablas como si nada.',
      'tipo': 'cara'
    },
  ];

  for (final p in preguntas) {
    await firestore.collection('preguntas').add(p);
  }

  print('✅ Preguntas y retos añadidos con éxito.');
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
