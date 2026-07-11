import 'package:flutter/material.dart';

import '../themes/text_styles.dart';
import '../utils/adaptive_widgets/theme.dart';

class BottomMessage {
  static OverlayEntry? _currentEntry;

  static void showText(BuildContext context, String text,
      {Duration duration = const Duration(milliseconds: 1500)}) {
    _currentEntry?.remove();
    _currentEntry = null;

    final overlay = Overlay.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final bgColor = AdaptiveTheme.of(context).primaryColor.withOpacity(0.9);
    final textStyle =
        smallTextStyle(context, bold: false, opacity: 0.8).copyWith(
      color: colorScheme.onPrimary,
    );

    final entry = OverlayEntry(
      builder: (_) => _TopToast(
        text: text,
        textStyle: textStyle,
        backgroundColor: bgColor,
        onDismiss: () {
          _currentEntry?.remove();
          _currentEntry = null;
        },
      ),
    );

    _currentEntry = entry;
    overlay.insert(entry);

    Future.delayed(duration, () {
      _currentEntry?.remove();
      _currentEntry = null;
    });
  }
}

class _TopToast extends StatefulWidget {
  final String text;
  final TextStyle textStyle;
  final Color backgroundColor;
  final VoidCallback onDismiss;

  const _TopToast({
    required this.text,
    required this.textStyle,
    required this.backgroundColor,
    required this.onDismiss,
  });

  @override
  State<_TopToast> createState() => _TopToastState();
}

class _TopToastState extends State<_TopToast>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, -0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Positioned(
      top: topPadding + 12,
      left: 0,
      right: 0,
      child: SlideTransition(
        position: _slideAnim,
        child: FadeTransition(
          opacity: _fadeAnim,
          child: Center(
            child: IntrinsicWidth(
              child: Material(
                color: Colors.transparent,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: widget.backgroundColor,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Text(
                    widget.text,
                    style: widget.textStyle,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
