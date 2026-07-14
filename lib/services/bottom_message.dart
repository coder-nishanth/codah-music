import 'dart:async';
import 'package:flutter/material.dart';

import '../themes/text_styles.dart';
import '../utils/adaptive_widgets/theme.dart';

class BottomMessage {
  static OverlayEntry? _currentEntry;
  static OverlayState? _cachedOverlay;
  static Color? _cachedBgColor;
  static TextStyle? _cachedTextStyle;
  static final ValueNotifier<String> _textNotifier = ValueNotifier('');

  static void showText(BuildContext context, String text,
      {Duration duration = const Duration(milliseconds: 1500)}) {
    _cachedOverlay = Overlay.of(context);
    _cachedBgColor = AdaptiveTheme.of(context).primaryColor.withOpacity(0.9);
    _cachedTextStyle = smallTextStyle(context, bold: false, opacity: 0.8).copyWith(
      color: Theme.of(context).colorScheme.onPrimary,
    );
    _textNotifier.value = text;

    if (_currentEntry == null) {
      _currentEntry = OverlayEntry(
        builder: (_) => _TopToast(
          textNotifier: _textNotifier,
          textStyle: _cachedTextStyle!,
          backgroundColor: _cachedBgColor!,
        ),
      );
      _cachedOverlay!.insert(_currentEntry!);
    }

    _scheduleRemove(duration);
  }

  static void showOverlay(String text,
      {Duration duration = const Duration(milliseconds: 1500)}) {
    if (_cachedOverlay == null) return;
    _textNotifier.value = text;
    _scheduleRemove(duration);
  }

  static Timer? _removeTimer;

  static void _scheduleRemove(Duration duration) {
    _removeTimer?.cancel();
    _removeTimer = Timer(duration, () {
      _currentEntry?.remove();
      _currentEntry = null;
    });
  }
}

class _TopToast extends StatefulWidget {
  final ValueNotifier<String> textNotifier;
  final TextStyle textStyle;
  final Color backgroundColor;

  const _TopToast({
    required this.textNotifier,
    required this.textStyle,
    required this.backgroundColor,
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
    widget.textNotifier.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    widget.textNotifier.removeListener(_onTextChanged);
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
                    widget.textNotifier.value,
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
