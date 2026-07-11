import 'package:flutter/material.dart';

class AnimatedCodahTitle extends StatefulWidget {
  final double fontSize;
  final double letterSpacing;

  const AnimatedCodahTitle({
    super.key,
    this.fontSize = 15,
    this.letterSpacing = 1.2,
  });

  @override
  State<AnimatedCodahTitle> createState() => _AnimatedCodahTitleState();
}

class _AnimatedCodahTitleState extends State<AnimatedCodahTitle>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  static const _text = 'CODAH MUSIC';

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(_text.length, (index) {
            final char = _text[index];
            if (char == ' ') {
              return SizedBox(width: widget.fontSize * 0.35);
            }
            final totalLetters = _text.replaceAll(' ', '').length;
            final offset = index / totalLetters;
            final value = (_controller.value - offset) % 1.0;
            final scale = 1.0 + 0.3 * (1.0 - (value * 2 - 1).abs());
            return Transform.scale(
              scale: scale,
              child: Text(
                char,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: widget.fontSize,
                  fontWeight: FontWeight.bold,
                  letterSpacing: widget.letterSpacing,
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
