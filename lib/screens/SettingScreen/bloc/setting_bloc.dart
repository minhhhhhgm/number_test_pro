import 'package:flutter_bloc/flutter_bloc.dart';
import 'setting_event.dart';
import 'setting_state.dart';

class SettingBloc extends Bloc<SettingEvent, SettingState> {
  SettingBloc() : super(const SettingState()) {
    on<LoadSetting>(_onLoadSetting);
    on<ToggleSound>(_onToggleSound);
    on<ToggleEffect>(_onToggleEffect);
    on<ToggleVibration>(_onToggleVibration);
    on<ChangeDifficulty>(_onChangeDifficulty);
    on<ChangeTheme>(_onChangeTheme);
    on<ChangeUserName>(_onChangeUserName);
    on<ResetData>(_onResetData);
  }

  void _onLoadSetting(LoadSetting event, Emitter<SettingState> emit) {
    // TODO: Load setting từ local storage nếu cần
    emit(state.copyWith(loading: false));
  }

  void _onToggleSound(ToggleSound event, Emitter<SettingState> emit) {
    emit(state.copyWith(sound: !state.sound));
  }

  void _onToggleEffect(ToggleEffect event, Emitter<SettingState> emit) {
    emit(state.copyWith(effect: !state.effect));
  }

  void _onToggleVibration(ToggleVibration event, Emitter<SettingState> emit) {
    emit(state.copyWith(vibration: !state.vibration));
  }

  void _onChangeDifficulty(ChangeDifficulty event, Emitter<SettingState> emit) {
    emit(state.copyWith(difficulty: event.difficulty));
  }

  void _onChangeTheme(ChangeTheme event, Emitter<SettingState> emit) {
    emit(state.copyWith(theme: event.theme));
  }

  void _onChangeUserName(ChangeUserName event, Emitter<SettingState> emit) {
    emit(state.copyWith(userName: event.userName));
  }

  void _onResetData(ResetData event, Emitter<SettingState> emit) {
    emit(const SettingState());
  }
} 