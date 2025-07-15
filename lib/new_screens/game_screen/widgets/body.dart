part of '../game_screen.dart';

class _Body extends StatelessWidget {
  const _Body();

  Future<void> _showStatusAlert({
    required IconData icon,
    required Color color,
    required BuildContext context,
  }) async {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        Future.delayed(Duration(seconds: 1), () {
          if (Navigator.of(dialogContext).canPop()) {
            Navigator.of(dialogContext).pop();
          }
        });

        return AlertDialog(
          backgroundColor: Colors.white.withOpacity(0),
          content: Container(
            width: 100,
            height: 100,
            child: Icon(
              icon,
              color: color,
              size: 100,
            ),
          ),
        );
      },
    );
  }

  Future<void> showGameSummaryDialog({
    required BuildContext context,
    required int correctAnswers,
    required int incorrectAnswers,
    required int score,
    required VoidCallback onReplay,
    required VoidCallback onHome,
  }) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: Colors.white,
          titlePadding: const EdgeInsets.only(top: 24),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          title: Column(
            children: [
              const Text(
                "Game Over",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Icon(Icons.emoji_events, color: Colors.orange, size: 64),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Correct answers: $correctAnswers"),
              Text("Incorrect answers: $incorrectAnswers"),
              Text("Total score: $score"),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  minimumSize: const Size.fromHeight(40),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(dialogContext);
                  onReplay();
                },
                child: const Text("Play Again"),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(40),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(dialogContext);
                  onHome();
                },
                child: const Text("Home"),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
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
                correctAnswers: 7,
                incorrectAnswers: 3,
                score: 70,
                onReplay: () {
                  // Gọi lại game
                },
                onHome: () {
                  // Về trang chủ
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
              child: BlocSelector<GameBloc, GameState, int>(
                selector: (state) => state.secCounter,
                builder: (context, secCounter) {
                  return _Header(
                    secCounter: secCounter,
                    score: 6,
                  );
                },
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            Text(
              'Target',
              style: TextStyle(
                fontSize: 32,
                color: Color(0xFF647c27),
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            BlocSelector<GameBloc, GameState, int>(
              selector: (state) => state.target,
              builder: (context, target) {
                return Text(
                  target.toString(),
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF647c27),
                  ),
                );
              },
            ),
            ElevatedButton(
              onPressed: () {
                context.read<GameBloc>().add(HintUsed());
              },
              child: Text('Hint'),
            ),
            BlocSelector<GameBloc, GameState, List<BlockSchemaNew>>(
              selector: (state) => state.blocksNew,
              builder: (context, blocks) {
                return _NumberBlocks(blocks: blocks);
              },
            ),
            const SizedBox(
              height: 80,
            ),
          ],
        ),
      ),
    );
  }
}
