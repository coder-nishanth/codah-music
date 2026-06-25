import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../services/window_service.dart';

class CustomTitleBar extends StatelessWidget {
  const CustomTitleBar({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onPanStart: (details) {
        const MethodChannel('flutter/window').invokeMethod('startDrag');
      },
      onDoubleTap: () async {
        await WindowService.maximize();
      },
      child: Container(
        height: 32,
        color: Colors.transparent,
        child: Row(
          children: [
            const Spacer(),
            _WindowButton(
              icon: Icons.minimize,
              onTap: () => WindowService.minimize(),
            ),
            _WindowButton(
              icon: Icons.crop_square,
              onTap: () => WindowService.maximize(),
            ),
            _WindowButton(
              icon: Icons.close,
              onTap: () => WindowService.close(),
              isClose: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _WindowButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool isClose;

  const _WindowButton({
    required this.icon,
    required this.onTap,
    this.isClose = false,
  });

  @override
  State<_WindowButton> createState() => _WindowButtonState();
}

class _WindowButtonState extends State<_WindowButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          width: 46,
          height: 32,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: _isHovered
                ? (widget.isClose
                    ? Colors.redAccent
                    : Colors.white.withValues(alpha: 0.1))
                : Colors.transparent,
          ),
          child: Icon(
            widget.icon,
            size: 16,
            color: Colors.white.withValues(alpha: _isHovered ? 1.0 : 0.7),
          ),
        ),
      ),
    );
  }
}
