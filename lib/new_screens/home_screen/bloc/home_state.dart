// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'home_bloc.dart';

class HomeState extends Equatable {
  final bool isReviewMode;
  final int selectedIndex;
  final Locale? currentLocale;
  final int? score, point;

  const HomeState(
      {this.isReviewMode = true,
      this.selectedIndex = 0,
      this.currentLocale,
      this.score = 0,
      this.point = 0});

  @override
  List<Object?> get props =>
      [isReviewMode, selectedIndex, currentLocale, score, point];

  HomeState copyWith(
      {bool? isReviewMode,
      int? selectedIndex,
      Locale? currentLocale,
      int? score,
      int? point}) {
    return HomeState(
        isReviewMode: isReviewMode ?? this.isReviewMode,
        selectedIndex: selectedIndex ?? this.selectedIndex,
        currentLocale: currentLocale ?? this.currentLocale,
        score: score ?? this.score,
        point: point ?? this.point);
  }
}
