import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class TermsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Términos y Condiciones')),
      body: FutureBuilder(
        future: rootBundle.loadString('assets/terms.md'),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Markdown(
              data: snapshot.data!,
              styleSheet:
                  MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
                h1: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                p: TextStyle(fontSize: 16),
              ),
            );
          } else {
            return Center(
              child: LoadingAnimationWidget.stretchedDots(
                  color: Theme.of(context).colorScheme.primary, size: 75),
            );
          }
        },
      ),
    );
  }
}
