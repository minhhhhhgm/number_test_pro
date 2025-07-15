import 'package:equatable/equatable.dart';

class HomeState extends Equatable {
  final int bestScore;
  final String userName;
  final bool loading;
  final String? error;

  const HomeState({
    this.bestScore = 0,
    this.userName = '',
    this.loading = false,
    this.error,
  });

  HomeState copyWith({
    int? bestScore,
    String? userName,
    bool? loading,
    String? error,
  }) {
    return HomeState(
      bestScore: bestScore ?? this.bestScore,
      userName: userName ?? this.userName,
      loading: loading ?? this.loading,
      error: error,
    );
  }

  @override
  List<Object?> get props => [bestScore, userName, loading, error];
} 