import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../services/settings_manager.dart';
import '../widgets/setting_item.dart';
import 'cubit/player_settings_cubit.dart';

class PlayerSettingsPage extends StatelessWidget {
  const PlayerSettingsPage({super.key});

  String _qualityLabel(AudioQuality q) =>
      q == AudioQuality.high ? 'High' : 'Low';

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PlayerSettingsCubit(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Player"),
        ),
        body: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: BlocBuilder<PlayerSettingsCubit, PlayerSettingsState>(
              builder: (context, state) {
                final loaded = state as PlayerSettingsLoaded;
                return ListView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  children: [
                    GroupTitle(title: "Playback"),
                    SettingSwitchTile(
                      title: "Skip Silence",
                      subtitle: "Automatically skip silent parts of audio",
                      value: loaded.skipSilence,
                      leading: const Icon(Icons.fast_forward),
                      isFirst: true,
                      isLast: true,
                      onChanged: (value) {
                        context.read<PlayerSettingsCubit>().setSkipSilence(value);
                      },
                    ),
                    GroupTitle(title: "Quality"),
                    SettingTile(
                      title: "Streaming Quality",
                      subtitle: _qualityLabel(loaded.streamingQuality),
                      leading: const Icon(Icons.high_quality),
                      isFirst: true,
                      onTap: () {
                        final next = loaded.streamingQuality == AudioQuality.high
                            ? AudioQuality.low
                            : AudioQuality.high;
                        context.read<PlayerSettingsCubit>().setStreamingQuality(next);
                      },
                    ),
                    SettingTile(
                      title: "Download Quality",
                      subtitle: _qualityLabel(loaded.downloadQuality),
                      leading: const Icon(Icons.download_done),
                      isLast: true,
                      onTap: () {
                        final next = loaded.downloadQuality == AudioQuality.high
                            ? AudioQuality.low
                            : AudioQuality.high;
                        context.read<PlayerSettingsCubit>().setDownloadQuality(next);
                      },
                    ),
                    GroupTitle(title: "Audio"),
                    SettingSwitchTile(
                      title: "Equalizer",
                      subtitle: "Enable system equalizer",
                      value: loaded.equalizerEnabled,
                      leading: const Icon(Icons.equalizer),
                      isFirst: true,
                      onChanged: (value) {
                        context.read<PlayerSettingsCubit>().setEqualizerEnabled(value);
                      },
                    ),
                    SettingSwitchTile(
                      title: "Loudness Enhancer",
                      subtitle: "Boost audio loudness",
                      value: loaded.loudnessEnabled,
                      leading: const Icon(Icons.volume_up),
                      isLast: true,
                      onChanged: (value) {
                        context.read<PlayerSettingsCubit>().setLoudnessEnabled(value);
                      },
                    ),
                    if (loaded.loudnessEnabled) ...[
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Loudness Target: ${loaded.loudnessTargetGain.toStringAsFixed(1)} dB',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            Slider(
                              value: loaded.loudnessTargetGain,
                              min: -10.0,
                              max: 10.0,
                              divisions: 40,
                              onChanged: (value) {
                                context.read<PlayerSettingsCubit>().setLoudnessTargetGain(value);
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
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
