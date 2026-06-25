import 'package:flutter/material.dart';

class AdaptiveProgressRing extends StatelessWidget {
  final double? value;
  final double strokeWidth;
  final Color? backgroundColor;
  final Color? color;

  const AdaptiveProgressRing({
    super.key,
    this.value,
    this.strokeWidth = 4.5,
    this.backgroundColor,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return CircularProgressIndicator(
      value: value,
      strokeWidth: strokeWidth,
      backgroundColor: backgroundColor,
      color: color,
    );
  }
}
