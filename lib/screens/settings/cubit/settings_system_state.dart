part of 'settings_system_cubit.dart';

sealed class SettingsSystemState {
  const SettingsSystemState();
}

class SettingsSystemInitial extends SettingsSystemState {
  const SettingsSystemInitial();
}

class SettingsSystemLoaded extends SettingsSystemState {
  final bool? isBatteryOptimizationDisabled;

  const SettingsSystemLoaded({
    required this.isBatteryOptimizationDisabled,
  });
}
