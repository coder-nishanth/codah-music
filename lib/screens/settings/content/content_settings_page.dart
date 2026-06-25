import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../../services/settings_manager.dart';
import '../widgets/setting_item.dart';

class ContentSettingsPage extends StatelessWidget {
  const ContentSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = GetIt.I<SettingsManager>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Content"),
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            children: [
              GroupTitle(title: "Library"),
              SettingSwitchTile(
                title: "Auto-fetch Song Info",
                subtitle: "Automatically fetch song details when added to library",
                value: settings.autofetchSongs,
                leading: const Icon(Icons.auto_fix_high),
                isFirst: true,
                isLast: true,
                onChanged: (value) {
                  settings.autofetchSongs = value;
                },
              ),
              GroupTitle(title: "Appearance"),
              SettingSwitchTile(
                title: "AMOLED Black",
                subtitle: "Use pure black background for OLED displays",
                value: settings.amoledBlack,
                leading: const Icon(Icons.contrast),
                isFirst: true,
                onChanged: (value) {
                  settings.amoledBlack = value;
                },
              ),
              SettingSwitchTile(
                title: "Dynamic Colors",
                subtitle: "Use album art colors for theming",
                value: settings.dynamicColors,
                leading: const Icon(Icons.palette),
                isLast: true,
                onChanged: (value) {
                  settings.dynamicColors = value;
                },
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }
}
