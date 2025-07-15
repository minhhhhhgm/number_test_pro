part of '../home_screen_new.dart';

class _BodyHome extends StatefulWidget {
  const _BodyHome();

  @override
  State<_BodyHome> createState() => _BodyHomeState();
}

class _BodyHomeState extends State<_BodyHome>
    with AutomaticKeepAliveClientMixin {
  void _onNavigateGameScreen(GameDifficulty gameMode) {
    final config = getIt<GameConfig>();
    config.updateFromDifficulty(gameMode);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => GameScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
            SafeArea(
                top: true,
                child: SizedBox(
                  height: 8,
                )),
            Center(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withValues(alpha: 0.5),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                padding: EdgeInsets.symmetric(vertical: 9, horizontal: 9),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/icon/point_icon.png',
                          width: 40,
                          height: 32,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 5.0),
                          child: Text(
                            '100',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        )
                      ],
                    ),
                    SizedBox(
                      width: 16,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/icon/coins.png',
                          width: 40,
                          height: 32,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 5.0),
                          child: BlocSelector<HomeBloc, HomeState, int?>(
                            selector: (state) => state.score,
                            builder: (context, score) {
                              return Text(
                                score.toString(),
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              );
                            },
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(
              height: 32,
            ),
            Image.asset(
              'assets/icon/game_icon.png',
              height: 150,
            ),

            SizedBox(
              height: 32,
            ),

            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Color(0xFFf3f1ed),
                        border: Border(
                          top: BorderSide(width: 1.0, color: Color(0xFFe6e8e7)),
                          left:
                              BorderSide(width: 1.0, color: Color(0xFFe6e8e7)),
                          right:
                              BorderSide(width: 1.0, color: Color(0xFFe6e8e7)),
                        ),
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(28),
                            topRight: Radius.circular(28)),
                      ),
                      child: SingleChildScrollView(
                        child: Padding(
                            padding: const EdgeInsets.all(22.0),
                            child: Column(
                              children: [
                                SizedBox(height: 16),
                                _GameMode(
                                  titleGame: '🟢 Easy Mode',
                                  descriptionGame:
                                      'Thư giãn đầu óc, chơi vui là chính',
                                  iconGamePath: 'assets/icon/easy.png',
                                  backgroundColor: Color(0xFF92ae4a),
                                  borderColor: Color(0xFF64762f),
                                  gameMode: GameDifficulty.easy,
                                  onTap: (gameMode) =>
                                      _onNavigateGameScreen(gameMode),
                                ),
                                SizedBox(height: 16),
                                _GameMode(
                                  titleGame: '🟠 Normal Mode',
                                  descriptionGame:
                                      'Tập trung và thể hiện kỹ năng',
                                  iconGamePath: 'assets/icon/easy.png',
                                  backgroundColor: Color(0xFFe99143),
                                  borderColor: Color(0xFF91521f),
                                  gameMode: GameDifficulty.normal,
                                  onTap: (gameMode) =>
                                      _onNavigateGameScreen(gameMode),
                                ),
                                SizedBox(height: 16),
                                _GameMode(
                                  titleGame: '🔴 Hard Mode',
                                  descriptionGame:
                                      'Căng não, thử thách giới hạn',
                                  iconGamePath: 'assets/icon/easy.png',
                                  backgroundColor: Color(0xFFc5e4f5),
                                  borderColor: Color(0xFF79a6bb),
                                  gameMode: GameDifficulty.hard,
                                  onTap: (gameMode) =>
                                      _onNavigateGameScreen(gameMode),
                                ),
                                SizedBox(height: 16),
                                _GameMode(
                                  titleGame: '🟣 Crazy Mode',
                                  descriptionGame:
                                      'Nhanh tay lẹ mắt, thần tốc cực độ!',
                                  iconGamePath: 'assets/icon/easy.png',
                                  backgroundColor: Color(0xFF9b59b6),
                                  borderColor: Color(0xFF6f2d91),
                                  gameMode: GameDifficulty.crazy,
                                  onTap: (gameMode) =>
                                      _onNavigateGameScreen(gameMode),
                                ),
                              ],
                            )),
                      ),
                    ),
                  );
                },
              ),
            ),

            // DailyStreakCard(),

            // // Stats overview
            // StatsOverviewCard(),

            // // Quick actions
            // QuickActionsCard(),

            // // Game modes
            // GameModesGrid(),
          ],
        ));
  }

  @override
  bool get wantKeepAlive => true;
}
