import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../core/widgets/animated_codah_title.dart';
import '../../generated/l10n.dart';
import '../../services/window_service.dart';
import 'widgets/bottom_player.dart';
import 'widgets/square_mini_player.dart';

class AppShell extends StatefulWidget {
  const AppShell({
    Key? key,
    required this.navigationShell,
  }) : super(key: key ?? const ValueKey('AppShell'));
  final StatefulNavigationShell navigationShell;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int get _selectedIndex => widget.navigationShell.currentIndex;

  void _onNavTap(int index) {
    widget.navigationShell.goBranch(index, initialLocation: true);
  }

  @override
  Widget build(BuildContext context) {
    final currentPath = GoRouterState.of(context).uri.toString();
    final isSearch = currentPath == '/search';
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Row(
        children: [
          Container(
            width: 60,
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(
                  color: Theme.of(context).dividerColor.withValues(alpha: 0.2),
                  width: 0.5,
                ),
              ),
            ),
            child: Column(
              children: [
                const Spacer(),
                _SidebarBtn(
                  icon: Icons.home_rounded,
                  label: S.of(context).Home,
                  selected: _selectedIndex == 0 && !isSearch,
                  onTap: () => _onNavTap(0),
                ),
                const SizedBox(height: 4),
                _SidebarBtn(
                  icon: Icons.search_rounded,
                  label: 'Search',
                  selected: isSearch,
                  onTap: () => context.go('/search'),
                ),
                const SizedBox(height: 4),
                _SidebarBtn(
                  icon: Icons.library_music_rounded,
                  label: S.of(context).Saved,
                  selected: _selectedIndex == 1,
                  onTap: () => _onNavTap(1),
                ),
                const SizedBox(height: 4),
                _SidebarBtn(
                  icon: Icons.settings_rounded,
                  label: S.of(context).Settings,
                  selected: _selectedIndex == 2,
                  onTap: () => _onNavTap(2),
                ),
                const SizedBox(height: 4),
                _SidebarBtn(
                  icon: Icons.favorite_rounded,
                  label: 'Support',
                  selected: _selectedIndex == 3,
                  onTap: () => _onNavTap(3),
                ),
                const Spacer(),
                const SizedBox(height: 16),
              ],
            ),
          ),
          Expanded(
            child: Column(
              children: [
                SizedBox(
                  height: 44,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onPanStart: (_) {
                            const MethodChannel('flutter/window')
                                .invokeMethod('startWindowDragging');
                          },
                          onDoubleTap: () => WindowService.maximize(),
                        ),
                      ),
                      const Center(
                        child: Row(
                          children: [
                            SizedBox(width: 16),
                            AnimatedCodahTitle(),
                            Spacer(),
                            _MacOSTrafficLights(),
                            SizedBox(width: 16),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Stack(
                    children: [
                      widget.navigationShell,
                      if (currentPath == '/')
                        const Align(
                          alignment: Alignment.bottomCenter,
                          child: BottomPlayer(),
                        )
                      else if (currentPath == '/support')
                        const SizedBox.shrink()
                      else
                        const Positioned(
                          bottom: 12,
                          right: 12,
                          child: SquareMiniPlayer(),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

}

class _SidebarBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _SidebarBtn({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: label,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: selected ? Colors.white.withValues(alpha: 0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            size: 20,
            color: selected
                ? Colors.white
                : Colors.white.withValues(alpha: 0.4),
          ),
        ),
      ),
    );
  }
}

class _MacOSTrafficLights extends StatefulWidget {
  const _MacOSTrafficLights();

  @override
  State<_MacOSTrafficLights> createState() => _MacOSTrafficLightsState();
}

class _MacOSTrafficLightsState extends State<_MacOSTrafficLights> {
  bool _closeHovered = false;
  bool _minHovered = false;
  bool _maxHovered = false;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _TrafficDot(
          baseColor: const Color(0xFFFF5F57),
          hoverColor: const Color(0xFFE0443E),
          icon: Icons.close,
          hovered: _closeHovered,
          onEnter: () => setState(() => _closeHovered = true),
          onExit: () => setState(() => _closeHovered = false),
          onTap: () => WindowService.close(),
        ),
        const SizedBox(width: 10),
        _TrafficDot(
          baseColor: const Color(0xFFFFBD2E),
          hoverColor: const Color(0xFFE0A325),
          icon: Icons.remove,
          hovered: _minHovered,
          onEnter: () => setState(() => _minHovered = true),
          onExit: () => setState(() => _minHovered = false),
          onTap: () => WindowService.minimize(),
        ),
        const SizedBox(width: 10),
        _TrafficDot(
          baseColor: const Color(0xFF28C840),
          hoverColor: const Color(0xFF1D9B30),
          icon: Icons.fullscreen,
          hovered: _maxHovered,
          onEnter: () => setState(() => _maxHovered = true),
          onExit: () => setState(() => _maxHovered = false),
          onTap: () => WindowService.maximize(),
        ),
      ],
    );
  }
}

class _TrafficDot extends StatelessWidget {
  final Color baseColor;
  final Color hoverColor;
  final IconData icon;
  final bool hovered;
  final VoidCallback onEnter;
  final VoidCallback onExit;
  final VoidCallback onTap;

  const _TrafficDot({
    required this.baseColor,
    required this.hoverColor,
    required this.icon,
    required this.hovered,
    required this.onEnter,
    required this.onExit,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => onEnter(),
      onExit: (_) => onExit(),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            color: hovered ? hoverColor : baseColor,
            shape: BoxShape.circle,
            boxShadow: [
              if (hovered)
                BoxShadow(
                  color: baseColor.withValues(alpha: 0.6),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
            ],
          ),
          child: Center(
            child: Icon(
              icon,
              size: 12,
              color: hovered ? Colors.black87 : Colors.transparent,
            ),
          ),
        ),
      ),
    );
  }
}
