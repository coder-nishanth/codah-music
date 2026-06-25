part of 'player_settings_cubit.dart';

@immutable
sealed class PlayerSettingsState {
  const PlayerSettingsState();
}

class PlayerSettingsLoaded extends PlayerSettingsState {
  final bool skipSilence;
  final AudioQuality streamingQuality;
  final AudioQuality downloadQuality;
  final bool equalizerEnabled;
  final bool loudnessEnabled;
  final double loudnessTargetGain;

  const PlayerSettingsLoaded({
    required this.skipSilence,
    required this.streamingQuality,
    required this.downloadQuality,
    required this.equalizerEnabled,
    required this.loudnessEnabled,
    required this.loudnessTargetGain,
  });
}
