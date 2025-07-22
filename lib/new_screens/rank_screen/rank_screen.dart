import 'dart:math';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:numbers/models/rank_model.dart';
import 'package:numbers/new_screens/home_screen/bloc/home_bloc.dart';
import 'package:numbers/new_screens/rank_screen/bloc/rank_bloc.dart';

part './widgets/build_top.dart';
part './widgets/player_avatar.dart';

class RankScreen extends StatelessWidget {
  const RankScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => RankBloc(RankState())..add(GetRankEvent()),
      child: _BodyRank(),
    );
  }
}

class _BodyRank extends StatelessWidget {
  const _BodyRank();

  Future<void> _showSetNameDialog(BuildContext context) async {
    context.read<RankBloc>().add(ResetStateEvent());
    await showDialog(
      context: context,
      builder: (dialogContext) {
        return BlocProvider.value(
          value: context.read<RankBloc>(),
          child: AlertDialog(
            backgroundColor: Colors.white,
            title: Text('enter_player_info'.tr()),
            content: BlocSelector<RankBloc, RankState, String?>(
              selector: (state) => state.errorName,
              builder: (context, errorName) {
                return TextField(
                  decoration: InputDecoration(
                      hintText: 'enter_your_name'.tr(),
                      errorText: errorName == '' ? null : errorName),
                  onChanged: (value) => context
                      .read<RankBloc>()
                      .add(NameChangeEvent(name: value)),
                );
              },
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: Text('cancel'.tr()),
              ),
              ElevatedButton(
                style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.white)),
                onPressed: () async {
                  final score = context.read<HomeBloc>().state.score;
                  context
                      .read<RankBloc>()
                      .add(SaveNameEvent(score: score ?? 0));
                  // if (context.watch<RankBloc>().state.errorName != null) {
                  //   Navigator.pop(dialogContext);
                  // }
                },
                child: BlocSelector<RankBloc, RankState, bool>(
                  selector: (state) => state.loadingSetName,
                  builder: (context, loadingSetName) {
                    if (loadingSetName) {
                      return BlocListener<RankBloc, RankState>(
                        listenWhen: (previous, current) =>
                            previous.loadingSetName != current.loadingSetName,
                        listener: (context, state) {
                          if (!state.loadingSetName &&
                              state.errorName == 'No error') {
                            Navigator.pop(dialogContext);
                          }
                        },
                        child: SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator()),
                      );
                    }
                    return Text('fight'.tr());
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: Color(0xFFF0E0B8).withOpacity(0.7),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.only(
                  top: 50, left: 20, right: 20, bottom: 20),
              color: const Color(0xFFF0E0B8).withOpacity(0.7),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'leader_board'.tr(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFF5D5D5D),
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  // const SizedBox(height: 20),
                  BlocSelector<RankBloc, RankState, bool>(
                    selector: (state) => state.loading,
                    builder: (context, loading) {
                      if (loading) {
                        return const CircularProgressIndicator();
                      }
                      return BlocSelector<RankBloc, RankState, List<RankModel>>(
                        selector: (state) => state.listRank ?? [],
                        builder: (context, listRank) {
                          final top3 = listRank.take(3).toList();
                          return _BuildTop(top3: top3);
                        },
                      );
                    },
                  )
                ],
              ),
            ),
            Expanded(
              child: Stack(
                children: [
                  /// ListView chính
                  Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    padding: const EdgeInsets.only(
                      left: 20,
                      right: 20,
                      top: 20,
                    ), // thêm bottom padding để tránh bị che
                    child: BlocSelector<RankBloc, RankState, bool>(
                      selector: (state) => state.loading,
                      builder: (context, loading) {
                        if (loading) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                        return BlocSelector<RankBloc, RankState,
                            List<RankModel>>(
                          selector: (state) => state.listRank ?? [],
                          builder: (context, listRank) {
                            final restOfLeaders = listRank.skip(3).toList();
                            return ListView.builder(
                              controller: context.read<RankBloc>().controller,
                              padding: EdgeInsets.zero,
                              itemCount: restOfLeaders.length,
                              itemBuilder: (context, index) {
                                final entry = restOfLeaders[index];
                                final isLastItem =
                                    index == restOfLeaders.length - 1;
                                return Animate(
                                  key: ValueKey(
                                      '${index}_${entry.isCurrentPlayer}'),
                                  effects: entry.isCurrentPlayer
                                      ? [
                                          ShakeEffect(
                                            duration: 800.ms,
                                            hz: 4,
                                            offset: const Offset(2, 2),
                                            curve: Curves.easeInOut,
                                          ),
                                          TintEffect(
                                            color:
                                                Colors.orange.withOpacity(0.1),
                                            duration: 800.ms,
                                          ),
                                        ]
                                      : [],
                                  onPlay: (controller) => controller.repeat(
                                      period: Duration(seconds: 3), count: 4),
                                  child: Column(
                                    children: [
                                      Container(
                                        margin:
                                            const EdgeInsets.only(bottom: 10),
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 10, horizontal: 15),
                                        decoration: BoxDecoration(
                                          color: entry.isCurrentPlayer
                                              ? Colors.blueAccent
                                                  .withOpacity(0.2)
                                              : Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(15),
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  Colors.grey.withOpacity(0.1),
                                              spreadRadius: 1,
                                              blurRadius: 5,
                                              offset: const Offset(0, 3),
                                            ),
                                          ],
                                          border: Border.all(
                                              color: Color(0xFF5B6E64),
                                              width: 2),
                                        ),
                                        child: Row(
                                          children: [
                                            SizedBox(
                                              width: 30,
                                              child: Text(
                                                '${entry.rank < 10 ? '0' : ''}${entry.rank}',
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xFF5D5D5D),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 15),
                                            _PlayerAvatar(
                                              playerName: entry.name,
                                              radius: 20,
                                            ),
                                            const SizedBox(width: 15),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    entry.name,
                                                    style: const TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: Color(0xFF5D5D5D),
                                                    ),
                                                  ),
                                                  Row(
                                                    children: [
                                                      Image.asset(
                                                        'assets/icon/star.png',
                                                        width: 16,
                                                        height: 16,
                                                      ),
                                                      const SizedBox(width: 2),
                                                      Text(
                                                        '${entry.highScore}',
                                                        style: const TextStyle(
                                                          fontSize: 14,
                                                          color: Colors.black,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (isLastItem)
                                        const SizedBox(
                                          height: 80,
                                        )
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                        );
                      },
                    ),
                  ),

                  /// Nút đua rank nếu không phải người chơi hiện tại
                  BlocSelector<RankBloc, RankState, (bool, bool, int?)>(
                    selector: (state) => (
                      state.isRegisterRank,
                      state.isOnTop,
                      state.currentRank
                    ),
                    builder: (context, record) {
                      final isRegisterRank = record.$1;
                      // final isOnTop = record.$2;
                      // final currentRank = record.$3;

                      return Positioned(
                        left: 20,
                        right: 20,
                        bottom: 20,
                        child: GestureDetector(
                          onTap: () {
                            if (!isRegisterRank) {
                              _showSetNameDialog(context);
                              return;
                            }
                            context
                                .read<HomeBloc>()
                                .add(UpdateSelectedIndex(selectedIndex: 0));
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 15),
                            decoration: BoxDecoration(
                              color: Color(0xFFF0E0B8),
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: Color(0xFFF0E0B8),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            alignment: Alignment.center,
                            child: BlocSelector<RankBloc, RankState, String?>(
                              selector: (state) => state.currentName,
                              builder: (context, currentName) {
                                return Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'start_rank_now'
                                          .tr(namedArgs: {'name': ''}),
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF5B6E64),
                                      ),
                                    ),
                                    if (currentName != null)
                                      Text(
                                        ' ${currentName.toString()}',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blue,
                                        ),
                                      ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
