import 'package:flutter/material.dart';
import 'package:proyecto_aa/screens/privacy_page.dart';
import 'package:proyecto_aa/screens/terms_page.dart';

class LegalPage extends StatelessWidget {
  const LegalPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Información Legal')),
      body: ListView(
        children: [
          const SizedBox(height: 10),
          Padding(
              padding: const EdgeInsets.only(left: 15),
              child: Text(
                "Legal",
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
                    leading: Icon(Icons.privacy_tip),
                    title: Text('Política de privacidad'),
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => PrivacyPage())),
                  ),
                  Padding(
                      padding: EdgeInsets.symmetric(horizontal: 15),
                      child: Divider()),
                  ListTile(
                      leading: Icon(Icons.description),
                      title: Text('Términos de uso'),
                      onTap: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => TermsPage()))),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
