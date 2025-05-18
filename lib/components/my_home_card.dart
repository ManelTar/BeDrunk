import 'package:flutter/material.dart';

class MyHomeCard extends StatelessWidget {
  final String nombreCard;
  final Function()? onTap;
  final bool isSelected;

  const MyHomeCard({
    super.key,
    required this.nombreCard,
    required this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: isSelected
            ? colorScheme.primary.withOpacity(0.8) // color cuando está activo
            : colorScheme.surfaceTint, // color normal
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Text(
            nombreCard,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isSelected
                  ? colorScheme.onPrimary // contraste sobre primary
                  : colorScheme.onSurface, // contraste normal
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
