import 'package:flutter/services.dart';

class WindowService {
  static const _channel = MethodChannel('river_music/window');

  static Future<void> minimize() async {
    await _channel.invokeMethod('minimize');
  }

  static Future<void> maximize() async {
    await _channel.invokeMethod('maximize');
  }

  static Future<void> close() async {
    await _channel.invokeMethod('close');
  }
}
