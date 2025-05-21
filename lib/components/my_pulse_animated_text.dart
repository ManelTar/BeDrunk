import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';

class ConstantPulseAnimatedText extends AnimatedText {
  final double minScale;
  final double maxScale;

  ConstantPulseAnimatedText(
    String text, {
    TextAlign textAlign = TextAlign.start,
    TextStyle? textStyle,
    Duration duration = const Duration(milliseconds: 1000),
    this.minScale = 0.9,
    this.maxScale = 1.1,
  }) : super(
          text: text,
          textAlign: textAlign,
          textStyle: textStyle,
          duration: duration,
        );

  late Animation<double> _scale;

  @override
  void initAnimation(AnimationController controller) {
    _scale = Tween<double>(begin: minScale, end: maxScale).animate(
      CurvedAnimation(
        parent: controller,
        curve: Curves.easeInOut,
      ),
    );

    controller.repeat(reverse: true);
  }

  @override
  Widget completeText(BuildContext context) {
    // El texto nunca desaparece, así que mostramos el mismo widget
    return textWidget(text);
  }

  @override
  Widget animatedBuilder(BuildContext context, Widget? child) {
    return ScaleTransition(
      scale: _scale,
      child: textWidget(text),
    );
  }
}
