import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';

import '../../../../../../services/media_player.dart';
import '../../../../../../services/settings_manager.dart';

part 'player_settings_state.dart';

class PlayerSettingsCubit extends Cubit<PlayerSettingsState> {
  final SettingsManager _settings = GetIt.I<SettingsManager>();
  final MediaPlayer _player = GetIt.I<MediaPlayer>();

  late final VoidCallback _listener;

  PlayerSettingsCubit()
      : super(
          PlayerSettingsLoaded(
            skipSilence: GetIt.I<SettingsManager>().skipSilence,
            streamingQuality: GetIt.I<SettingsManager>().streamingQuality,
            downloadQuality: GetIt.I<SettingsManager>().downloadQuality,
            equalizerEnabled: GetIt.I<SettingsManager>().equalizerEnabled,
            loudnessEnabled: GetIt.I<SettingsManager>().loudnessEnabled,
            loudnessTargetGain: GetIt.I<SettingsManager>().loudnessTargetGain,
          ),
        ) {
    _listener = () {
      if (!isClosed) {
        _emitState();
      }
    };

    _settings.addListener(_listener);
  }

  void _emitState() {
    if (isClosed) return;

    emit(
      PlayerSettingsLoaded(
        skipSilence: _settings.skipSilence,
        streamingQuality: _settings.streamingQuality,
        downloadQuality: _settings.downloadQuality,
        equalizerEnabled: _settings.equalizerEnabled,
        loudnessEnabled: _settings.loudnessEnabled,
        loudnessTargetGain: _settings.loudnessTargetGain,
      ),
    );
  }

  Future<void> setSkipSilence(bool value) async {
    await _player.skipSilence(value);
    _settings.skipSilence = value;
  }

  void setStreamingQuality(AudioQuality value) {
    _settings.streamingQuality = value;
  }

  void setDownloadQuality(AudioQuality value) {
    _settings.downloadQuality = value;
  }

  void setEqualizerEnabled(bool value) {
    _settings.equalizerEnabled = value;
  }

  void setLoudnessEnabled(bool value) {
    _settings.loudnessEnabled = value;
  }

  void setLoudnessTargetGain(double value) {
    _settings.loudnessTargetGain = value;
  }

  @override
  Future<void> close() {
    _settings.removeListener(_listener);
    return super.close();
  }
}
