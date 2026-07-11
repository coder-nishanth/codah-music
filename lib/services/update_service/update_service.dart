import 'dart:convert';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:Codah/services/update_service/models/update_info.dart';
import 'package:Codah/services/update_service/widgets/update_checking.dart';
import 'package:Codah/services/update_service/widgets/update_dialog.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:Codah/services/bottom_message.dart';

class UpdateService {
  static const String owner = 'iad1tya';
  static const String repo = 'codah-music';

  static Future<UpdateInfo?> checkForUpdate() async {
    try {
      final package = await PackageInfo.fromPlatform();
      final currentVersion = Version.parse(package.version);

      final Uri uri = Uri.parse(
        'https://raw.githubusercontent.com/iad1tya/codah-music/main/desktop_update.json',
      );

      final response = await http.get(uri);

      if (response.statusCode != 200) return null;

      final Map<String, dynamic> data = jsonDecode(response.body);
      final String remoteVersionString = data['version']?.toString() ?? '1.0.0';
      
      Version remoteVersion;
      try {
        remoteVersion = Version.parse(remoteVersionString);
      } catch (e) {
        final parts = remoteVersionString.split('.');
        if (parts.length == 2) {
          remoteVersion = Version.parse('$remoteVersionString.0');
        } else if (parts.length == 1) {
           remoteVersion = Version.parse('$remoteVersionString.0.0');
        } else {
           return null;
        }
      }

      if (remoteVersion > currentVersion) {
        return UpdateInfo(
          version: remoteVersion,
          name: 'New Update Available',
          body: 'A new version of CODAH MUSIC is available. Please update to continue.',
          publishedAt: '',
          downloadUrl: 'https://codahmusic.fun',
        );
      }
      
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<void> autoCheck(BuildContext context) async {
    final update = await checkForUpdate();
    if (update == null || !context.mounted) return;

    await showUpdateDialog(context, update);
  }

  static Future<void> manualCheck(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      useRootNavigator: false,
      builder: (_) => const UpdateCheckingDialog(),
    );

    final update = await checkForUpdate();

    if (!context.mounted) return;
    Navigator.pop(context);

    if (update != null) {
      await showUpdateDialog(context, update);
    } else {
      BottomMessage.showText(context, 'You are already on the latest version');
    }
  }

  static Future<void> showUpdateDialog(
    BuildContext context,
    UpdateInfo info,
  ) {
    return showDialog(
      context: context,
      useRootNavigator: false,
      builder: (_) => UpdateDialog(info),
    );
  }
}
