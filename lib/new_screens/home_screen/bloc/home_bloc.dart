import 'dart:async';
import 'dart:developer';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:numbers/di/service_locator.dart';
import 'package:numbers/provider/BlockDataStream.dart';
import 'package:numbers/service/score_service.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  late PageController pageController;
  final blockDataStream = getIt<BlockDataStream>();
  final scoreService = getIt<ScoreService>();
  StreamSubscription<int>? _scoreSubscription;

  HomeBloc(super.initialState) {
    pageController = PageController();
    on<InitEvent>(_onInit);
    on<UpdateSelectedIndex>(_mapUpdateSelectedIndex);
    on<UpdatePageChangeEvent>(_mapUpdatePageChangeEvent);
    on<UpdateScoreEvent>(_onUpdateScore);
    _scoreSubscription = blockDataStream.scoreStream.listen((score) {
      log('Score change $score');
      add(UpdateScoreEvent(score: score));
    });

    add(InitEvent());
  }

  @override
  Future<void> close() async {
    pageController.dispose();
    _scoreSubscription?.cancel();
    return super.close();
  }

  void _onUpdateScore(UpdateScoreEvent event, Emitter<HomeState> emit) async {
    emit(state.copyWith(score: event.score));
  }

  void _onInit(InitEvent event, Emitter<HomeState> emit) async {
    final score = await scoreService.getScore();
    emit(state.copyWith(score: score));
  }

  void _mapUpdateSelectedIndex(
    UpdateSelectedIndex event,
    Emitter<HomeState> emit,
  ) {
    final index = event.selectedIndex;
    emit(state.copyWith(
      selectedIndex: index,
    ));
    pageController.jumpToPage(index);
  }

  void _mapUpdatePageChangeEvent(
    UpdatePageChangeEvent event,
    Emitter<HomeState> emit,
  ) {
    final pageChange = event.pageChange;
    int selectedIndex = pageChange;

    emit(state.copyWith(
      selectedIndex: selectedIndex,
    ));
  }
}
