import 'package:equatable/equatable.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();
  @override
  List<Object?> get props => [];
}

class LoadHomeData extends HomeEvent {}
class UpdateBestScore extends HomeEvent {
  final int bestScore;
  const UpdateBestScore(this.bestScore);
  @override
  List<Object?> get props => [bestScore];
}
class UpdateUserName extends HomeEvent {
  final String userName;
  const UpdateUserName(this.userName);
  @override
  List<Object?> get props => [userName];
} 