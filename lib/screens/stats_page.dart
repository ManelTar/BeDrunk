import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class StatsPage extends StatelessWidget {
  const StatsPage({super.key});

  Future<Map<String, dynamic>> _fetchStats(String uid) async {
    final doc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    return doc.data() ?? {};
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: Text("Estadísticas")),
        body: Center(child: Text("No has iniciado sesión")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Estadísticas"),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _fetchStats(user.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: LoadingAnimationWidget.stretchedDots(
                  color: Theme.of(context).colorScheme.primary, size: 75),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text("No hay estadísticas disponibles"),
            );
          }

          final data = snapshot.data!;
          final int tragoCount = data['tragos'] ?? 0;
          final int ganadas = data['partidasGanadas'] ?? 0;
          final int perdidas = data['partidasPerdidas'] ?? 0;
          final int totales = data['partidasTotales'] ?? 0;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildStatCard("Tragos", tragoCount, Icons.local_bar),
                SizedBox(height: 16),
                _buildStatCard("Partidas Ganadas", ganadas, Icons.emoji_events),
                SizedBox(height: 16),
                _buildStatCard("Partidas Perdidas", perdidas,
                    Icons.sentiment_dissatisfied),
                SizedBox(height: 16),
                _buildStatCard(
                    "Partidas Totales", totales, Icons.videogame_asset),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard(String label, int value, IconData icon) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, size: 36, color: Colors.deepPurple),
        title: Text(
          label,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        trailing: Text(
          value.toString(),
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
