import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../generated/l10n.dart';
import '../../themes/text_styles.dart';
import '../../utils/adaptive_widgets/adaptive_widgets.dart';
import 'widgets/setting_item.dart';
import 'cubit/settings_system_cubit.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SettingsSystemCubit()..load(),
      child: AdaptiveScaffold(
        appBar: AdaptiveAppBar(
          title: Text(
            S.of(context).Settings,
            style: appBarTitleStyle(),
          ),
          automaticallyImplyLeading: false,
        ),
        body: BlocBuilder<SettingsSystemCubit, SettingsSystemState>(
          builder: (context, state) {
            return Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 1000),
                child: ListView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  children: [
                    GroupTitle(title: "Services"),
                    SettingTile(
                      title: "Youtube Music",
                      leading: const Icon(Icons.play_circle_fill),
                      isFirst: true,
                      isLast: true,
                      onTap: () => context.go('/settings/services/ytmusic'),
                    ),
                    GroupTitle(title: "Audio"),
                    SettingTile(
                      title: S.of(context).Equalizer,
                      leading: const Icon(Icons.equalizer),
                      isFirst: true,
                      isLast: true,
                      onTap: () => context.go('/settings/equalizer'),
                    ),
                    GroupTitle(title: "Privacy"),
                    SettingTile(
                      title: "Privacy",
                      leading: const Icon(Icons.privacy_tip),
                      isFirst: true,
                      isLast: true,
                      onTap: () => context.go('/settings/privacy'),
                    ),
                    GroupTitle(title: "About"),
                    SettingTile(
                      title: S.of(context).About,
                      leading: const Icon(Icons.info_rounded),
                      isFirst: true,
                      onTap: () => context.go('/settings/about'),
                    ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}


