import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:proyecto_aa/screens/firstTime_user_page.dart';
import 'package:proyecto_aa/screens/main_page.dart';

class CheckUserProfile extends StatelessWidget {
  const CheckUserProfile({super.key});

  Future<bool> perfilCompletado(String uid) async {
    final doc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    return doc.exists && doc.data()?['profileCompleted'] == true;
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return FutureBuilder<bool>(
      future: perfilCompletado(uid),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: LoadingAnimationWidget.stretchedDots(
                color: Theme.of(context).colorScheme.primary, size: 75),
          );
        }

        final completado = snapshot.data!;
        return completado ? const MainPage() : const FirsttimeUserPage();
      },
    );
  }
}
