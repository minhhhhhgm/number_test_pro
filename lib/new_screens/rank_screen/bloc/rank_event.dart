part of 'rank_bloc.dart';

abstract class RankEvent {}

class InitEvent extends RankEvent {}

class GetRankEvent extends RankEvent {}

class NameChangeEvent extends RankEvent {
  final String name;

  NameChangeEvent({required this.name});
}

class SaveNameEvent extends RankEvent {
  final int score;

  SaveNameEvent({required this.score});
}

class ResetStateEvent extends RankEvent {}
