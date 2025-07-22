part of '../game_screen.dart';

class _Header extends StatelessWidget {
  const _Header(
      {required this.secCounter,
      required this.score,
      required this.textColor,
      required this.backgroundColorCountDown,
      required this.foregroundColorCountDown,
      required this.borderColor});

  final int secCounter;
  final int score;
  final Color textColor,
      borderColor,
      backgroundColorCountDown,
      foregroundColorCountDown;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(
          height: 16,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 35,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: borderColor, width: 2),
                  borderRadius: BorderRadius.circular(8)),
              child: Text(
                secCounter.toString().padLeft(2, '0') + '(s)',
                style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(
              width: 16,
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
                            color: textColor, fontWeight: FontWeight.bold),
                      )
                    ],
                  );
                },
              ),
            )
          ],
        ),
        const SizedBox(
          height: 16,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: BlocSelector<GameBloc, GameState, (int, bool)>(
            selector: (state) => (state.secCounter, state.triggerCountdown),
            builder: (context, state) {
              return CountdownBar(
                key: ValueKey('${state.$2}'),
                durationInSeconds: state.$1,
                onFinish: () {},
                backgroundColor: backgroundColorCountDown,
                foregroundColor: foregroundColorCountDown,
              );
            },
          ),
        ),
      ],
    );
  }
}

class CountdownBar extends StatefulWidget {
  final int durationInSeconds;
  final Color backgroundColor;
  final Color foregroundColor;
  final VoidCallback? onFinish;

  const CountdownBar({
    Key? key,
    this.durationInSeconds = 1000,
    this.backgroundColor = const Color(0xFF637c27), // nhạt
    this.foregroundColor = const Color(0xFF96e94d), // đậm#
    this.onFinish,
  }) : super(key: key);

  @override
  State<CountdownBar> createState() => _CountdownBarState();
}

class _CountdownBarState extends State<CountdownBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _startAnimation(widget.durationInSeconds);
  }

  void _startAnimation(int durationInSeconds) {
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: widget.durationInSeconds),
    )..forward();

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed && widget.onFinish != null) {
        widget.onFinish!();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(99),
      child: Container(
        height: 6,
        width: double.infinity,
        color: widget.backgroundColor,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: 1 - _controller.value,
              child: Container(color: widget.foregroundColor),
            );
          },
        ),
      ),
    );
  }
}
