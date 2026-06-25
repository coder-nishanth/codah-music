import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../../generated/l10n.dart';
import '../../../services/settings_manager.dart';
import '../widgets/setting_item.dart';

class InterfaceSettingsPage extends StatelessWidget {
  const InterfaceSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = GetIt.I<SettingsManager>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Interface"),
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            children: [
              GroupTitle(title: "Language & Region"),
              SettingTile(
                title: "App Language",
                subtitle: settings.language['name'],
                leading: const Icon(Icons.language),
                isFirst: true,
                onTap: () => _showLanguagePicker(context, settings),
              ),
              SettingTile(
                title: "Content Region",
                subtitle: settings.location['name'],
                leading: const Icon(Icons.public),
                isLast: true,
                onTap: () => _showLocationPicker(context, settings),
              ),
              GroupTitle(title: "Navigation"),
              SettingTile(
                title: "Default Tab",
                subtitle: "Home",
                leading: const Icon(Icons.tab),
                isFirst: true,
                isLast: true,
                onTap: () {},
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  void _showLanguagePicker(BuildContext context, SettingsManager settings) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        constraints: const BoxConstraints(maxHeight: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Select Language',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: settings.languages.length,
                itemBuilder: (context, index) {
                  final lang = settings.languages[index];
                  final isSelected = lang['value'] == settings.language['value'];
                  return ListTile(
                    title: Text(lang['name']!, style: const TextStyle(color: Colors.white)),
                    trailing: isSelected
                        ? const Icon(Icons.check, color: Colors.white)
                        : null,
                    onTap: () {
                      settings.language = lang;
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLocationPicker(BuildContext context, SettingsManager settings) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        constraints: const BoxConstraints(maxHeight: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Select Region',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: settings.locations.length,
                itemBuilder: (context, index) {
                  final loc = settings.locations[index];
                  final isSelected = loc['value'] == settings.location['value'];
                  return ListTile(
                    title: Text(loc['name']!, style: const TextStyle(color: Colors.white)),
                    trailing: isSelected
                        ? const Icon(Icons.check, color: Colors.white)
                        : null,
                    onTap: () {
                      settings.location = loc;
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
