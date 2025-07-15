import 'package:equatable/equatable.dart';
import 'setting_event.dart';

class SettingState extends Equatable {
  final bool sound;
  final bool effect;
  final bool vibration;
  final Difficulty difficulty;
  final AppTheme theme;
  final String userName;
  final bool loading;
  final String? error;

  const SettingState({
    this.sound = true,
    this.effect = true,
    this.vibration = true,
    this.difficulty = Difficulty.normal,
    this.theme = AppTheme.light,
    this.userName = '',
    this.loading = false,
    this.error,
  });

  SettingState copyWith({
    bool? sound,
    bool? effect,
    bool? vibration,
    Difficulty? difficulty,
    AppTheme? theme,
    String? userName,
    bool? loading,
    String? error,
  }) {
    return SettingState(
      sound: sound ?? this.sound,
      effect: effect ?? this.effect,
      vibration: vibration ?? this.vibration,
      difficulty: difficulty ?? this.difficulty,
      theme: theme ?? this.theme,
      userName: userName ?? this.userName,
      loading: loading ?? this.loading,
      error: error,
    );
  }

  @override
  List<Object?> get props => [sound, effect, vibration, difficulty, theme, userName, loading, error];
} 