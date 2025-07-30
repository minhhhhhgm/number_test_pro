part of '../game_screen.dart';

class _Body extends StatelessWidget {
  const _Body(
      {required this.textColor,
      required this.borderColor,
      required this.backgroundColorCountDown,
      required this.foregroundColorCountDown});

  final Color textColor,
      borderColor,
      backgroundColorCountDown,
      foregroundColorCountDown;

  static OverlayEntry? _statusAlertOverlayEntry;

  Future<void> _showStatusAlert({
    required IconData icon,
    required Color color,
    required BuildContext context,
  }) async {
    if (_statusAlertOverlayEntry != null) {
      _statusAlertOverlayEntry?.remove();
      _statusAlertOverlayEntry = null;
    }

    _statusAlertOverlayEntry = OverlayEntry(
      builder: (overlayContext) {
        Future.delayed(const Duration(seconds: 1), () {
          if (_statusAlertOverlayEntry != null &&
              _statusAlertOverlayEntry!.mounted) {
            _statusAlertOverlayEntry?.remove();
            _statusAlertOverlayEntry = null;
          }
        });

        return Stack(
          children: [
            Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: SizedBox(
                  width: 100,
                  height: 100,
                  child: Icon(
                    icon,
                    color: color,
                    size: 100,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );

    Overlay.of(context).insert(_statusAlertOverlayEntry!);
  }

  void _dismissStatusAlert() {
    if (_statusAlertOverlayEntry != null && _statusAlertOverlayEntry!.mounted) {
      _statusAlertOverlayEntry?.remove();
      _statusAlertOverlayEntry = null;
    }
  }

  Future<void> showGameSummaryDialog({
    required BuildContext context,
    required int correctAnswers,
    required int incorrectAnswers,
    required int score,
    required VoidCallback onReplay,
    required VoidCallback onHome,
  }) async {
    _dismissStatusAlert();
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return PopScope(
          canPop: false,
          child: AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            backgroundColor: Colors.white,
            titlePadding: const EdgeInsets.only(top: 24),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            title: Column(
              children: [
                Text(
                  "game_over".tr(),
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: textColor),
                ),
                const SizedBox(height: 12),
                Icon(Icons.emoji_events, color: Colors.orange, size: 64),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "${'correct_answers'.tr()} $correctAnswers",
                  style: TextStyle(color: textColor),
                ),
                Text("${'incorrect_answers'.tr()} $incorrectAnswers",
                    style: TextStyle(color: textColor)),
                Text("${'total_score'.tr()} $score",
                    style: TextStyle(color: textColor)),
                const SizedBox(height: 24),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: backgroundColorCountDown,
                    minimumSize: const Size.fromHeight(40),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(dialogContext);
                    onReplay();
                  },
                  child: Text(
                    "play_again".tr(),
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: borderColor,
                    minimumSize: const Size.fromHeight(40),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(dialogContext);
                    onHome();
                  },
                  child: Text("home".tr(), style: TextStyle(color: textColor)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: MultiBlocListener(
        listeners: [
          BlocListener<GameBloc, GameState>(
            listenWhen: (previous, current) =>
                previous.triggerAnswerQuestion != current.triggerAnswerQuestion,
            listener: (context, state) {
              final soundService = getIt<MainSoundService>();
              if (state.isCorrectAnswer) {
                soundService.playCorrectSound();
                _showStatusAlert(
                  icon: Icons.check,
                  color: Colors.green,
                  context: context,
                );
                context.read<GameBloc>().add(NextTurn());
              }

              if (state.isInCorrectAnswer) {
                soundService.playIncorrectSound();
                _showStatusAlert(
                  icon: Icons.clear,
                  color: Colors.red,
                  context: context,
                );
                context.read<GameBloc>().add(NextTurn());
              }
            },
          ),
          BlocListener<GameBloc, GameState>(
            listenWhen: (previous, current) =>
                previous.isTimeUp != current.isTimeUp,
            listener: (context, state) {
              if (state.isTimeUp) {
                // if (Navigator.of(context).canPop()) {
                //   Navigator.of(context).pop();
                // }
                showGameSummaryDialog(
                  context: context,
                  correctAnswers: state.correctAnswers,
                  incorrectAnswers: state.wrongAnswers,
                  score: state.score,
                  onReplay: () {
                    context.read<GameBloc>().add(PlayAgain());
                  },
                  onHome: () {
                    context.read<GameBloc>().add(GameDone());
                    Navigator.of(context).pop();
                  },
                );
              }
            },
          ),
        ],
        child: SingleChildScrollView(
          child: Column(
            children: [
              SafeArea(
                top: true,
                child: BlocSelector<GameBloc, GameState, GameDifficulty>(
                  selector: (state) => state.gameDifficulty,
                  builder: (context, gameDifficulty) {
                    if (gameDifficulty != GameDifficulty.chill) {
                      return BlocSelector<GameBloc, GameState, int>(
                        selector: (state) => state.secCounter,
                        builder: (context, secCounter) {
                          return _Header(
                            secCounter: secCounter,
                            score: 6,
                            textColor: textColor,
                            backgroundColorCountDown: backgroundColorCountDown,
                            foregroundColorCountDown: foregroundColorCountDown,
                            borderColor: borderColor,
                            onBack: () {
                              showGameSummaryDialog(
                                context: context,
                                correctAnswers: context
                                    .read<GameBloc>()
                                    .state
                                    .correctAnswers,
                                incorrectAnswers:
                                    context.read<GameBloc>().state.wrongAnswers,
                                score: context.read<GameBloc>().state.score,
                                onReplay: () {
                                  context.read<GameBloc>().add(PlayAgain());
                                },
                                onHome: () {
                                  context.read<GameBloc>().add(GameDone());
                                  Navigator.of(context).pop();
                                },
                              );
                            },
                          );
                        },
                      );
                    }
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 16.0),
                          child: InkWell(
                              onTap: () {
                                showGameSummaryDialog(
                                  context: context,
                                  correctAnswers: context
                                      .read<GameBloc>()
                                      .state
                                      .correctAnswers,
                                  incorrectAnswers: context
                                      .read<GameBloc>()
                                      .state
                                      .wrongAnswers,
                                  score: context.read<GameBloc>().state.score,
                                  onReplay: () {
                                    context.read<GameBloc>().add(PlayAgain());
                                  },
                                  onHome: () {
                                    context.read<GameBloc>().add(GameDone());
                                    Navigator.of(context).pop();
                                  },
                                );
                              },
                              child: Icon(Icons.arrow_back_ios)),
                        ),
                        Container(
                          height: 35,
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: borderColor, width: 2),
                              borderRadius: BorderRadius.circular(8)),
                          child: BlocSelector<GameBloc, GameState, int>(
                            selector: (state) => state.score,
                            builder: (context, score) {
                              return Row(
                                children: [
                                  Image.asset(
                                    'assets/icon/star.png',
                                    width: 24,
                                    height: 24,
                                  ),
                                  SizedBox(
                                    width: 2,
                                  ),
                                  Text(
                                    '$score',
                                    style: TextStyle(
                                        color: textColor,
                                        fontWeight: FontWeight.bold),
                                  )
                                ],
                              );
                            },
                          ),
                        ),
                        SizedBox(
                          width: 38,
                        )
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(
                height: 8,
              ),
              BlocSelector<GameBloc, GameState, int>(
                selector: (state) => state.target,
                builder: (context, target) {
                  return Animate(
                    key: ValueKey('${target}'),
                    effects: [ShakeEffect(duration: 300.ms, hz: 8)],
                    child: Text(
                      target.toString(),
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.w700,
                        color: textColor,
                      ),
                    ),
                  );
                },
              ),
              _ToolHelperWidget(
                borderColor: borderColor,
              ),
              SizedBox(
                height: 16,
              ),
              BlocSelector<GameBloc, GameState, List<BlockSchemaNew>>(
                selector: (state) => state.blocksNew,
                builder: (context, blocks) {
                  return _NumberBlocks(
                    blocks: blocks,
                    borderColor: borderColor,
                    textColor: textColor,
                  );
                },
              ),
              const SizedBox(
                height: 30,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
