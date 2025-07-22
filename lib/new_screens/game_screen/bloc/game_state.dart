import 'package:equatable/equatable.dart';
import 'package:numbers/di/service_locator.dart';
import 'package:numbers/utils/game_config.dart';

import '../../../schema/BlockSchema.dart';

class GameState extends Equatable {
  final int target;
  final List<BlockSchema> blocks;
  final List<BlockSchemaNew> blocksNew;

  final List<int> selectedIndexes;
  final int currentTotal;
  final int secCounter;
  final int score;
  final bool isTimeUp;
  final int hintCount;
  final bool isDoubleScoreActive;
  final bool isRevealBlockActive;
  final int? revealedBlockIndex;
  final GameStatus status;
  final String? message;
  final Duration countdown;
  final bool isCountingDown;
  final bool triggerAnswerQuestion, isCorrectAnswer, isInCorrectAnswer;
  final bool triggerCountdown;
  final int correctAnswers, wrongAnswers;

  const GameState(
      {required this.target,
      required this.blocks,
      required this.blocksNew,
      required this.selectedIndexes,
      required this.currentTotal,
      required this.secCounter,
      required this.score,
      required this.isTimeUp,
      required this.hintCount,
      required this.isDoubleScoreActive,
      required this.isRevealBlockActive,
      required this.revealedBlockIndex,
      required this.status,
      this.message,
      this.isCountingDown = false,
      this.countdown = const Duration(seconds: 60),
      this.triggerAnswerQuestion = false,
      this.isCorrectAnswer = false,
      this.isInCorrectAnswer = false,
      this.triggerCountdown = false,
      this.correctAnswers = 0,
      this.wrongAnswers = 0});

  factory GameState.initial() => GameState(
      target: 0,
      blocks: const [],
      blocksNew: const [],
      selectedIndexes: const [],
      currentTotal: 0,
      secCounter: getIt<GameConfig>().timePlay,
      score: 0,
      isTimeUp: false,
      hintCount: 0,
      isDoubleScoreActive: false,
      isRevealBlockActive: false,
      revealedBlockIndex: null,
      status: GameStatus.initial,
      message: null,
      triggerAnswerQuestion: false,
      isCorrectAnswer: false,
      isInCorrectAnswer: false,
      triggerCountdown: false,
      correctAnswers: 0,
      wrongAnswers: 0);

  GameState copyWith(
      {int? target,
      List<BlockSchema>? blocks,
      List<BlockSchemaNew>? blocksNew,
      List<int>? selectedIndexes,
      int? currentTotal,
      int? secCounter,
      int? score,
      bool? isTimeUp,
      int? hintCount,
      bool? isDoubleScoreActive,
      bool? isRevealBlockActive,
      int? revealedBlockIndex,
      GameStatus? status,
      String? message,
      Duration? countdown,
      bool? isCountingDown,
      bool? triggerAnswerQuestion,
      bool? isCorrectAnswer,
      bool? isInCorrectAnswer,
      bool? triggerCountdown,
      int? correctAnswers,
      int? wrongAnswers}) {
    return GameState(
        target: target ?? this.target,
        blocks: blocks ?? this.blocks,
        blocksNew: blocksNew ?? this.blocksNew,
        selectedIndexes: selectedIndexes ?? this.selectedIndexes,
        currentTotal: currentTotal ?? this.currentTotal,
        secCounter: secCounter ?? this.secCounter,
        score: score ?? this.score,
        isTimeUp: isTimeUp ?? this.isTimeUp,
        hintCount: hintCount ?? this.hintCount,
        isDoubleScoreActive: isDoubleScoreActive ?? this.isDoubleScoreActive,
        isRevealBlockActive: isRevealBlockActive ?? this.isRevealBlockActive,
        revealedBlockIndex: revealedBlockIndex ?? this.revealedBlockIndex,
        status: status ?? this.status,
        message: message,
        countdown: countdown ?? this.countdown,
        isCountingDown: isCountingDown ?? this.isCountingDown,
        triggerAnswerQuestion:
            triggerAnswerQuestion ?? this.triggerAnswerQuestion,
        isCorrectAnswer: isCorrectAnswer ?? this.isCorrectAnswer,
        isInCorrectAnswer: isInCorrectAnswer ?? this.isInCorrectAnswer,
        triggerCountdown: triggerCountdown ?? this.triggerCountdown,
        correctAnswers: correctAnswers ?? this.correctAnswers,
        wrongAnswers: wrongAnswers ?? this.wrongAnswers);
  }

  @override
  List<Object?> get props => [
        target,
        blocks,
        blocksNew,
        selectedIndexes,
        currentTotal,
        secCounter,
        score,
        isTimeUp,
        hintCount,
        isDoubleScoreActive,
        isRevealBlockActive,
        revealedBlockIndex,
        status,
        message,
        countdown,
        isCountingDown,
        triggerAnswerQuestion,
        isCorrectAnswer,
        isInCorrectAnswer,
        triggerCountdown,
        correctAnswers,
        wrongAnswers
      ];
}

enum GameStatus { initial, playing, win, lose, summary, paused }
