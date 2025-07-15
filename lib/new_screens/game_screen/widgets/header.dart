part of '../game_screen.dart';

class _Header extends StatelessWidget {
  const _Header({required this.secCounter, required this.score});

  final int secCounter;
  final int score;

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
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Color(0xFFbecaa1), width: 2),
                  borderRadius: BorderRadius.circular(8)),
              child: Text(
                secCounter.toString().padLeft(2, '0') + ':00',
                style: TextStyle(
                    color: Color(0xFF647c29), fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(
              width: 16,
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Color(0xFFbecaa1), width: 2),
                  borderRadius: BorderRadius.circular(8)),
              child: BlocSelector<GameBloc, GameState, int>(
                selector: (state) => state.score,
                builder: (context, score) {
                  return Text(
                    'Point : $score',
                    style: TextStyle(
                        color: Color(0xFF647c29), fontWeight: FontWeight.bold),
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
          child: BlocSelector<GameBloc, GameState, int>(
            selector: (state) => state.secCounter,
            builder: (context, secCounter) {
              return CountdownBar(
                durationInSeconds: secCounter,
                onFinish: () {},
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
