import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:numbers/di/service_locator.dart';
import 'package:numbers/models/leader_board_model.dart';
import 'package:numbers/models/rank_model.dart';
import 'package:numbers/service/leader_board_service.dart';
import 'package:numbers/new_screens/test_rank/service.dart';
import 'package:numbers/service/sound_service.dart';

part 'rank_event.dart';
part 'rank_state.dart';

class RankBloc extends Bloc<RankEvent, RankState> {
  final leaderBoardService = getIt<LeaderBoardService>();
  final rankService = getIt<Service>();
  final soundService = getIt<MainSoundService>();
  final ScrollController controller = ScrollController();

  RankBloc(super.initialState) {
    emit(state.copyWith(loading: true));
    on<InitEvent>((event, emit) async {
      try {
        final _currentDeviceId =
            await leaderBoardService.getDeviceId(); // Hoặc hàm public nếu có
        final _currentPlayerName =
            await leaderBoardService.getPlayerNameFromLocalStore();
        final currentName = await rankService.getPlayerName();
        log('user: ${_currentDeviceId} -- $_currentPlayerName --$currentName');
        final listData = await leaderBoardService.getTop10Leaderboard(
            leaderboardType: 'daily');
        final top3 = listData.take(3).toList();
        final restOfLeaders = listData.skip(3).toList();

        emit(state.copyWith(
            listData: listData, top3: top3, restOfLeaders: restOfLeaders));
      } catch (e) {
        print('error getTop10Leaderboard $e');
      } finally {
        emit(state.copyWith(loading: false));
      }
    });

    on<GetRankEvent>((event, emit) async {
      emit(state.copyWith(loading: true));
      int? currentRank;

      try {
        final currentDeviceId = await rankService.getDeviceId();
        final currentName = await rankService.getPlayerName();
        final top10 = await rankService.getTop10Leaderboard();
        final listRank = top10.map((e) {
          if (e.id == currentDeviceId) {
            currentRank = e.rank;
          }
          return e.copyWith(isCurrentPlayer: e.id == currentDeviceId);
        }).toList();

        emit(state.copyWith(
            currentDeviceId: currentDeviceId,
            currentName: currentName,
            listRank: listRank,
            currentRank: currentRank,
            isRegisterRank: currentName != null && currentName.isNotEmpty,
            isOnTop: currentRank != null));

        log('currentRank $currentRank -- isRegisterRank: $currentName  rank $currentRank');
      } catch (e) {
        log('err $e');
      } finally {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (currentRank != null &&
              currentRank! >= 5 &&
              controller.hasClients) {
            controller.animateTo(
              (currentRank!.toDouble() - 3) * 70,
              duration: Duration(seconds: 2),
              curve: Curves.fastOutSlowIn,
            );
          }
        });

        emit(state.copyWith(loading: false));
        await soundService.playRankingMusic();
      }
    });

    on<NameChangeEvent>(
      (event, emit) {
        emit(state.copyWith(name: event.name));
      },
    );

    on<SaveNameEvent>(
      (event, emit) async {
        try {
          if (state.name == null || state.name == '') {
            log('name null');
            emit(state.copyWith(errorName: 'Vui lòng nhập tên !!!'));
            return;
          }
          emit(state.copyWith(loadingSetName: true));
          await rankService.setPlayerName(
              newName: state.name ?? '', score: event.score);
          emit(state.copyWith(
              isRegisterRank: true,
              errorName: 'No error',
              currentName: state.name));
          add(GetRankEvent());
        } on Exception catch (e) {
          emit(state.copyWith(
              errorName: e.toString().replaceFirst('Exception: ', '')));
        } finally {
          emit(state.copyWith(loadingSetName: false));
        }
      },
    );

    on<ResetStateEvent>(
      (event, emit) {
        emit(state.copyWith(errorName: '', name: ''));
      },
    );
  }

  @override
  Future<void> close() async {
    // TODO: implement close
    controller.dispose();
    await soundService.stopRankingMusic();
    return super.close();
  }
}
