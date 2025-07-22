part of 'rank_bloc.dart';

class RankState extends Equatable {
  const RankState(
      {this.listData,
      this.loading = false,
      this.top3,
      this.restOfLeaders,
      this.listRank,
      this.currentName,
      this.currentDeviceId,
      this.currentPlayer,
      this.isRegisterRank = false,
      this.isOnTop = false,
      this.currentRank,
      this.name,
      this.errorName,
      this.loadingSetName = false});

  final List<LeaderBoardModel>? listData;
  final List<LeaderBoardModel>? top3;
  final List<LeaderBoardModel>? restOfLeaders;

  final List<RankModel>? listRank;
  final String? currentName, currentDeviceId;
  final RankModel? currentPlayer;

  final bool loading;
  final bool loadingSetName;

  final bool isRegisterRank, isOnTop;
  final int? currentRank;
  final String? name, errorName;

  RankState copyWith(
      {List<LeaderBoardModel>? listData,
      bool? loading,
      List<LeaderBoardModel>? top3,
      List<LeaderBoardModel>? restOfLeaders,
      List<RankModel>? listRank,
      String? currentName,
      String? currentDeviceId,
      RankModel? currentPlayer,
      bool? isRegisterRank,
      bool? isOnTop,
      int? currentRank,
      String? name,
      String? errorName,
      bool? loadingSetName}) {
    return RankState(
        listData: listData ?? this.listData,
        loading: loading ?? this.loading,
        top3: top3 ?? this.top3,
        restOfLeaders: restOfLeaders ?? this.restOfLeaders,
        listRank: listRank ?? this.listRank,
        currentName: currentName ?? this.currentName,
        currentDeviceId: currentDeviceId ?? this.currentDeviceId,
        currentPlayer: currentPlayer ?? this.currentPlayer,
        isRegisterRank: isRegisterRank ?? this.isRegisterRank,
        isOnTop: isOnTop ?? this.isOnTop,
        currentRank: currentRank ?? this.currentRank,
        name: name ?? this.name,
        errorName: errorName ?? this.errorName,
        loadingSetName: loadingSetName ?? this.loadingSetName);
  }

  @override
  List<Object?> get props => [
        listData,
        loading,
        top3,
        restOfLeaders,
        listRank,
        currentName,
        currentDeviceId,
        currentPlayer,
        isRegisterRank,
        isOnTop,
        currentRank,
        name,
        errorName,
        loadingSetName
      ];
}
