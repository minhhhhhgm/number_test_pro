import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:numbers/di/service_locator.dart';
import 'package:numbers/provider/BlockDataStream.dart';
import 'package:numbers/service/score_service.dart';
import 'package:numbers/service/sound_service.dart';
import 'package:numbers/utils/game_config.dart';
import 'package:numbers/new_screens/test_rank/service.dart';

import '../../../schema/BlockSchema.dart';
import 'game_event.dart';
import 'game_state.dart';

class GameBloc extends Bloc<GameEvent, GameState> {
  late BlockSchemaNew blockSchemaNew;

  final blockDataStream = getIt<BlockDataStream>();
  final soundService = getIt<MainSoundService>();
  final scoreService = getIt<ScoreService>();
  final config = getIt<GameConfig>();
  final rankService = getIt<Service>();

  Timer? _timer;
  double currentTotal = 0;
  int totalScore = 0;
  int correctAnswers = 0;
  int wrongAnswers = 0;
  StreamSubscription<Map<String, int>>? _blockDataSubscription;

  GameBloc() : super(GameState.initial()) {
    on<GameStarted>(_onGameStarted);
    on<BlockSelected>(_onBlockSelected);
    // on<PowerUpUsed>(_onPowerUpUsed);
    on<HintUsed>(_onHintUsed);
    on<TimerTicked>(_onTimerTicked);
    on<NextTurn>(_onNextTurn);
    // on<GameEnded>(_onGameEnded);
    on<AddTime>(_onAddTime);
    on<PlayAgain>(_onPlayAgain);
    on<GameDone>(_onGameDone);
    on<ValidateBlocksEvent>(_onValidateBlocks);

    _blockDataSubscription = blockDataStream.stream.listen((data) {
      if (!isClosed) {
        add(ValidateBlocksEvent(blockData: data));
      }
    });
    soundService.playBackgroundMusic();
  }

  void _onValidateBlocks(
      ValidateBlocksEvent event, Emitter<GameState> emit) async {
    int selectedIndex = event.blockData['index'] ?? 0;

    final block = state.blocksNew[selectedIndex];

    if (block.isSelected) return;

    final updatedBlock = block.copyWith(
      isSelected: true,
      color: Colors.green,
    );

    final updatedList = List<BlockSchemaNew>.from(state.blocksNew);
    updatedList[selectedIndex] = updatedBlock;

    currentTotal += event.blockData['value'] as int;

    if (currentTotal < blockSchemaNew.target) {
      updatedList[selectedIndex] = updatedBlock.copyWith(color: Colors.green);

      if (!isThereChanceToMakeItCorrect()) {
        wrongAnswers += 1;
        updatedList[selectedIndex] = updatedBlock.copyWith(color: Colors.red);
        emit(state.copyWith(
            blocksNew: updatedList,
            triggerAnswerQuestion: !state.triggerAnswerQuestion,
            isInCorrectAnswer: true,
            isCorrectAnswer: false,
            wrongAnswers: wrongAnswers));
        return;
      }
    } else if (currentTotal == blockSchemaNew.target) {
      updatedList[selectedIndex] = updatedBlock.copyWith(color: Colors.green);
      totalScore += 1;
      correctAnswers += 1;
      log('correctAnswers $correctAnswers score : ${totalScore * config.pointBonus}');
      log('config.pointBonus ${config.pointBonus}');

      emit(state.copyWith(
          triggerAnswerQuestion: !state.triggerAnswerQuestion,
          isCorrectAnswer: true,
          isInCorrectAnswer: false,
          score: totalScore * config.pointBonus,
          correctAnswers: correctAnswers));
    } else {
      wrongAnswers += 1;
      updatedList[selectedIndex] = updatedBlock.copyWith(color: Colors.red);
      emit(state.copyWith(
          triggerAnswerQuestion: !state.triggerAnswerQuestion,
          isInCorrectAnswer: true,
          isCorrectAnswer: false,
          wrongAnswers: wrongAnswers));
    }

    emit(state.copyWith(blocksNew: updatedList));
  }

  bool isThereChanceToMakeItCorrect() {
    bool chance = false;

    for (var i = 0; i < state.blocksNew.length; i++) {
      if (state.blocksNew[i].isSelected) {
        continue;
      }

      if (currentTotal + state.blocksNew[i].value <= blockSchemaNew.target) {
        chance = true;
      }
    }

    return chance;
  }

  Future<void> _onGameStarted(
      GameStarted event, Emitter<GameState> emit) async {
    _startTimer(emit);
    _fillBlocksData(emit);
  }

  void _startTimer(Emitter<GameState> emit) {
    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      add(TimerTicked());
    });
  }

  void _fillBlocksData(Emitter<GameState> emit) {
    blockSchemaNew = BlockSchemaNew.random();
    final blocks = blockSchemaNew.generateBlocks();
    currentTotal = 0;

    emit(state.copyWith(
        target: blockSchemaNew.target, blocksNew: blocks, hintCount: 0));
  }

  Future<void> _onBlockSelected(
      BlockSelected event, Emitter<GameState> emit) async {
    blockDataStream.setCount(index: event.index, value: event.value);
  }

  // Future<void> _onPowerUpUsed(
  //     PowerUpUsed event, Emitter<GameState> emit) async {
  //   // Xử lý logic power-up tương ứng
  //   switch (event.type) {
  //     case PowerUpType.doubleScore:
  //       await soundService.playPowerUp();
  //       emit(state.copyWith(
  //           isDoubleScoreActive: true, message: 'X2 điểm đã kích hoạt!'));
  //       break;
  //     case PowerUpType.addTime:
  //       await soundService.playPowerUp();
  //       emit(state.copyWith(
  //           secCounter: state.secCounter + 20, message: 'Đã thêm 20 giây!'));
  //       break;
  //     case PowerUpType.skipLevel:
  //       await soundService.playPowerUp();
  //       add(NextTurn());
  //       break;
  //     case PowerUpType.revealBlock:
  //       await soundService.playPowerUp();
  //       // Reveal 1 block đúng
  //       int? revealIdx;
  //       for (int i = 0; i < state.blocks.length; i++) {
  //         if (!state.blocks[i].isSelected) {
  //           revealIdx = i;
  //           break;
  //         }
  //       }
  //       emit(state.copyWith(
  //           isRevealBlockActive: true,
  //           revealedBlockIndex: revealIdx,
  //           message: 'Đã hiển thị 1 block đúng!'));
  //       break;
  //   }
  // }

  Future<void> _onHintUsed(HintUsed event, Emitter<GameState> emit) async {
    if (state.blocksNew.isEmpty) return;

    int nextHintCount = state.hintCount + 1;

    final combination = state.blocksNew.first.correctCombination;

    if (state.hintCount >= combination.length) nextHintCount = 1;

    final hintNumbers =
        combination.take(nextHintCount).toList()[nextHintCount - 1];

    final updatedBlocks = state.blocksNew.map((block) {
      final shouldHint = hintNumbers == block.value;
      return block.copyWith(
          isHint: shouldHint, triggerHint: !block.triggerHint);
    }).toList();

    emit(state.copyWith(
      hintCount: nextHintCount,
      blocksNew: updatedBlocks,
    ));
  }

  void _onTimerTicked(TimerTicked event, Emitter<GameState> emit) async {
    if (state.secCounter <= 0) {
      _timer?.cancel();
      // await Future.delayed(Duration(seconds: 2));
      emit(state.copyWith(isTimeUp: true, message: 'Hết giờ!'));
      await soundService.stopBackgroundMusic();
      await soundService.pauseEffectSound();
    } else {
      emit(state.copyWith(secCounter: state.secCounter - 1));
    }
  }

  void _onNextTurn(NextTurn event, Emitter<GameState> emit) {
    _fillBlocksData(emit);
  }

  void _onAddTime(AddTime event, Emitter<GameState> emit) {
    emit(state.copyWith(
        secCounter: state.secCounter + 20,
        triggerCountdown: !state.triggerCountdown));
  }

  void _onPlayAgain(PlayAgain event, Emitter<GameState> emit) async {
    totalScore = 0;
    correctAnswers = 0;
    wrongAnswers = 0;
    emit(state.copyWith(
        triggerCountdown: !state.triggerCountdown,
        secCounter: config.timePlay,
        score: 0,
        isTimeUp: false));
    add(GameStarted());
    await soundService.playBackgroundMusic();
  }

  void _onGameDone(GameDone event, Emitter<GameState> emit) async {
    await scoreService.saveScore(total: totalScore * config.pointBonus);
    final score = await scoreService.getScore();
    // final point = await scoreService.getPoint();

    blockDataStream.setScore(score: score ?? 0);
    await rankService.updateHighScore(score: score ?? 0);
    // blockDataStream.setPoint(point: point ?? 0);
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    _blockDataSubscription?.cancel();
    soundService.stopBackgroundMusic();
    return super.close();
  }
}
