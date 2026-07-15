import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:scroll_animator/scroll_animator.dart';

import '../../../generated/l10n.dart';
import '../widgets/setting_item.dart';
import '../../../utils/adaptive_widgets/adaptive_widgets.dart';
import '../../../utils/bottom_modals.dart';

import 'cubit/appearance_cubit.dart';

class AppearancePage extends StatefulWidget {
  const AppearancePage({super.key});

  @override
  State<AppearancePage> createState() => _AppearancePageState();
}

class _AppearancePageState extends State<AppearancePage> {
  late final AnimatedScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = AnimatedScrollController(
      animationFactory: const ChromiumEaseInOut(),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AppearanceCubit(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(S.of(context).Appearence),
        ),
        body: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: BlocBuilder<AppearanceCubit, AppearanceState>(
              builder: (context, state) {
                final s = state as AppearanceLoaded;

                return ListView(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  children: [
                    GroupTitle(title: "Theme"),

                    SettingTile(
                      title: S.of(context).Theme_Mode,
                      leading: const Icon(Icons.dark_mode),
                      isFirst: true,
                      trailing: AdaptiveDropdownButton<ThemeMode>(
                        value: s.themeMode,
                        items: ThemeMode.values
                            .map(
                              (e) => AdaptiveDropdownMenuItem(
                                value: e,
                                child: Text(e.name.toUpperCase()),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value == null) return;
                          context.read<AppearanceCubit>().setThemeMode(value);
                        },
                      ),
                    ),

                    SettingSwitchTile(
                      title: S.of(context).Dynamic_Colors,
                      leading: const Icon(Icons.color_lens_outlined),
                      isLast: true,
                      value: s.dynamicColors,
                      onChanged: (value) {
                        context.read<AppearanceCubit>().setDynamicColors(value);
                      },
                    ),

                    GroupTitle(title: "Accent Color"),

                    SettingTile(
                      title: 'Accent Color',
                      leading: const Icon(Icons.colorize_rounded),
                      isFirst: true,
                      isLast: true,
                      trailing: CircleAvatar(
                        radius: 14,
                        backgroundColor: s.accentColor ?? Colors.blue,
                      ),
                      onTap: () => Modals.showAccentSelector(context),
                    ),

                    const SizedBox(height: 100),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
