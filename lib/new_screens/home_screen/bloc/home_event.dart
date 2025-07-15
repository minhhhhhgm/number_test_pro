part of 'home_bloc.dart';

abstract class HomeEvent {}

class InitEvent extends HomeEvent {}

class UpdateSelectedIndex extends HomeEvent {
  final int selectedIndex;

  UpdateSelectedIndex({required this.selectedIndex});
}

class UpdatePageChangeEvent extends HomeEvent {
  final int pageChange;

  UpdatePageChangeEvent({required this.pageChange});
}

class UpdateScoreEvent extends HomeEvent {
  final int score;

  UpdateScoreEvent({required this.score});
}
