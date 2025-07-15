import 'package:equatable/equatable.dart';

enum Difficulty { easy, normal, hard }
enum AppTheme { light, dark }

abstract class SettingEvent extends Equatable {
  const SettingEvent();
  @override
  List<Object?> get props => [];
}

class LoadSetting extends SettingEvent {}
class ToggleSound extends SettingEvent {}
class ToggleEffect extends SettingEvent {}
class ToggleVibration extends SettingEvent {}
class ChangeDifficulty extends SettingEvent {
  final Difficulty difficulty;
  const ChangeDifficulty(this.difficulty);
  @override
  List<Object?> get props => [difficulty];
}
class ChangeTheme extends SettingEvent {
  final AppTheme theme;
  const ChangeTheme(this.theme);
  @override
  List<Object?> get props => [theme];
}
class ChangeUserName extends SettingEvent {
  final String userName;
  const ChangeUserName(this.userName);
  @override
  List<Object?> get props => [userName];
}
class ResetData extends SettingEvent {} 