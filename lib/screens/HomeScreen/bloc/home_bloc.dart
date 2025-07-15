import 'package:flutter_bloc/flutter_bloc.dart';
import 'home_event.dart';
import 'home_state.dart';
import 'package:numbers/store/BestScoreStore.dart';
import 'package:numbers/store/SettingsStore.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc() : super(const HomeState()) {
    on<LoadHomeData>(_onLoadHomeData);
    on<UpdateBestScore>(_onUpdateBestScore);
    on<UpdateUserName>(_onUpdateUserName);
  }

  Future<void> _onLoadHomeData(LoadHomeData event, Emitter<HomeState> emit) async {
    emit(state.copyWith(loading: true));
    try {
      final bestScore = await BestScoreStore().getBestScore();
      final userName = await SettingsStore.instance.getKey('name') ?? '';
      emit(state.copyWith(bestScore: bestScore, userName: userName, loading: false));
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }

  void _onUpdateBestScore(UpdateBestScore event, Emitter<HomeState> emit) {
    emit(state.copyWith(bestScore: event.bestScore));
  }

  void _onUpdateUserName(UpdateUserName event, Emitter<HomeState> emit) {
    emit(state.copyWith(userName: event.userName));
  }
} 