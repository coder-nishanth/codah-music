import 'package:bloc/bloc.dart';

part 'settings_system_state.dart';

class SettingsSystemCubit extends Cubit<SettingsSystemState> {
  SettingsSystemCubit() : super(const SettingsSystemInitial());

  Future<void> load() async {
    emit(const SettingsSystemLoaded(
      isBatteryOptimizationDisabled: null,
    ));
  }

  Future<void> requestBatteryOptimizationIgnore() async {
    await load();
  }
}
