part of 'app_bloc.dart';

abstract class AppEvent {}

class ChangeLanguageEvent extends AppEvent {
  final String lang;

  ChangeLanguageEvent({required this.lang});
}
