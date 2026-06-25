import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/widgets/animated_river_title.dart';
import '../../core/widgets/common_header.dart';
import '../../generated/l10n.dart';
import '../../services/window_service.dart';
import 'widgets/bottom_player.dart';

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
  List<Map<String, dynamic>> _searchResults = [];
  bool _searchLoading = false;

  int get _selectedIndex => widget.navigationShell.currentIndex;

  void _onNavTap(int index) {
    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
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
                  icon: CupertinoIcons.music_house_fill,
                  label: S.of(context).Home,
                  selected: _selectedIndex == 0,
                  onTap: () => _onNavTap(0),
                ),
                const SizedBox(height: 4),
                _SidebarBtn(
                  icon: Icons.library_music_outlined,
                  label: S.of(context).Saved,
                  selected: _selectedIndex == 1,
                  onTap: () => _onNavTap(1),
                ),
                const SizedBox(height: 4),
                _SidebarBtn(
                  icon: CupertinoIcons.gear_alt_fill,
                  label: S.of(context).Settings,
                  selected: _selectedIndex == 2,
                  onTap: () => _onNavTap(2),
                ),
                const Spacer(),
                const SizedBox(height: 16),
              ],
            ),
          ),
          Expanded(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Row(
                    children: [
                      const AnimatedRiverTitle(),
                      const Spacer(),
                      SizedBox(
                        width: 400,
                        child: CommonHeader(
                          onResultsChanged: (results, loading) {
                            setState(() {
                              _searchResults = results;
                              _searchLoading = loading;
                            });
                          },
                        ),
                      ),
                      const Spacer(),
                      _WBtn(
                        icon: Icons.minimize,
                        onTap: () => WindowService.minimize(),
                      ),
                      _WBtn(
                        icon: Icons.crop_square,
                        onTap: () => WindowService.maximize(),
                      ),
                      _WBtn(
                        icon: Icons.close,
                        onTap: () => WindowService.close(),
                        isClose: true,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Stack(
                    children: [
                      widget.navigationShell,
                      if (_searchResults.isNotEmpty || _searchLoading)
                        Positioned(
                          top: 8,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: SizedBox(
                              width: 400,
                              child: _buildSearchOverlay(),
                            ),
                          ),
                        ),
                      const Align(
                        alignment: Alignment.bottomCenter,
                        child: BottomPlayer(),
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

  Widget _buildSearchOverlay() {
    return Container(
      constraints: const BoxConstraints(maxHeight: 400),
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.2),
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 20,
            spreadRadius: 0,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: _searchLoading && _searchResults.isEmpty
          ? const Padding(
              padding: EdgeInsets.all(20),
              child: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white54,
                  ),
                ),
              ),
            )
          : ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: ListView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(vertical: 4),
                itemCount: _searchResults.length,
                itemBuilder: (context, index) {
                  return SearchResultTile(item: _searchResults[index]);
                },
        ),
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

class _WBtn extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool isClose;

  const _WBtn({required this.icon, required this.onTap, this.isClose = false});

  @override
  State<_WBtn> createState() => _WBtnState();
}

class _WBtnState extends State<_WBtn> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          width: 36,
          height: 30,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: _hovered
                ? (widget.isClose
                    ? Colors.redAccent
                    : Colors.white.withValues(alpha: 0.1))
                : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(
            widget.icon,
            size: 14,
            color: Colors.white.withValues(alpha: _hovered ? 1.0 : 0.6),
          ),
        ),
      ),
    );
  }
}
