import 'package:flutter/material.dart';
import 'package:proyecto_aa/screens/account_page.dart';
import 'package:proyecto_aa/screens/help_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Ajustes"),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 10),
          Padding(
              padding: const EdgeInsets.only(left: 15),
              child: Text("Cuenta",
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
                    leading: Icon(Icons.account_box),
                    title: Text('Cuenta'),
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (_) => AccountPage()));
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Padding(
              padding: const EdgeInsets.only(left: 15),
              child: Text(
                "Centro de soporte",
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
                      leading: Icon(Icons.support_agent_rounded),
                      title: Text('Centro de soporte'),
                      onTap: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (_) => HelpPage()));
                      }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
