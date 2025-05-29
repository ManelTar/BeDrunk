import 'package:flutter/material.dart';
import 'package:in_app_review/in_app_review.dart';

class RateAppButton extends StatelessWidget {
  const RateAppButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        Icons.star_rate,
      ),
      title: Text('Valorar esta app'),
      onTap: () async {
        final InAppReview inAppReview = InAppReview.instance;

        if (await inAppReview.isAvailable()) {
          inAppReview.openStoreListing(); // Abre la tienda para valorar
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('No se puede abrir la tienda')),
          );
        }
      },
    );
  }
}
