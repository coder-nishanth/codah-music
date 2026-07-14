import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import '../../generated/l10n.dart';
import '../../services/settings_manager.dart';
import '../../services/update_service/update_service.dart';
import '../../themes/text_styles.dart';
import '../../utils/adaptive_widgets/adaptive_widgets.dart';
import 'widgets/setting_item.dart';
import 'cubit/settings_system_cubit.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = GetIt.I<SettingsManager>();
    return BlocProvider(
      create: (_) => SettingsSystemCubit()..load(),
      child: ListenableBuilder(
        listenable: settings,
        builder: (context, _) {
          return AdaptiveScaffold(
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
                        SettingTile(
                          title: "Check for Updates",
                          leading: settings.hasUpdate
                              ? Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    const Icon(Icons.system_update),
                                    Positioned(
                                      top: -2,
                                      right: -2,
                                      child: Container(
                                        width: 8,
                                        height: 8,
                                        decoration: const BoxDecoration(
                                          color: Colors.redAccent,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              : const Icon(Icons.system_update),
                          isLast: true,
                          onTap: () => UpdateService.manualCheck(context),
                        ),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}


