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
      MaterialPageRoute(
          builder: (context) => GameScreen(
                borderColor: config.borderColor,
                textColor: config.textColor,
                backgroundColorCountDown: config.backgroundColorCountDown,
                foregroundColorCountDown: config.foregroundColorCountDown,
                backgroundColor: config.backgroundColor,
              )),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      // backgroundColor: Color(0xFFF0E0B8),
      body: Stack(fit: StackFit.expand, children: [
        // ImageFiltered(
        //   imageFilter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        //   child: Image.asset(
        //     'assets/images/test_image.jpg',
        //     fit: BoxFit.cover,
        //   ),
        // ),
        CustomScrollView(
          slivers: [
            SliverAppBar.large(
              backgroundColor: Color(0xFFF0E0B8),
              pinned: true,
              expandedHeight: 250,
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: true,
                background: Stack(
                  fit: StackFit.expand, // Đảm bảo Stack lấp đầy không gian
                  children: [
                    ImageFiltered(
                      imageFilter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                      child: Image.asset(
                        'assets/images/test_image.jpg',
                        fit: BoxFit.fill,
                      ),
                    ),
                    // Lớp phủ màu
                    Container(color: Color(0xFFF0E0B8).withOpacity(0.7)),
                  ],
                ),
                title: Container(
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  padding: EdgeInsets.symmetric(vertical: 5, horizontal: 12),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 3.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/icon/star.png',
                              width: 32,
                              height: 32,
                            ),
                            SizedBox(width: 2),
                            BlocSelector<HomeBloc, HomeState, int?>(
                              selector: (state) => state.score,
                              builder: (context, score) {
                                return Text(
                                  score.toString(),
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Container(
                decoration: BoxDecoration(
                  // color: Color(0xFFf3f1ed),
                  border: Border(
                    top: BorderSide(width: 1.0, color: Color(0xFFe6e8e7)),
                    left: BorderSide(width: 1.0, color: Color(0xFFe6e8e7)),
                    right: BorderSide(width: 1.0, color: Color(0xFFe6e8e7)),
                  ),
                  // borderRadius: BorderRadius.only(
                  //   topLeft: Radius.circular(28),
                  //   topRight: Radius.circular(28),
                  // ),
                ),
                padding: const EdgeInsets.all(22.0),
                child: Column(
                  children: [
                    _GameMode(
                      titleGame: '🟢 Easy Mode',
                      descriptionGame: tr('relax_mode'),
                      iconGamePath: 'assets/icon/easy_ic.png',
                      backgroundColor: Color(0xFF92ae4a),
                      borderColor: Color(0xFF64762f),
                      gameMode: GameDifficulty.easy,
                      onTap: (gameMode) => _onNavigateGameScreen(gameMode),
                    ),
                    SizedBox(height: 16),
                    _GameMode(
                      titleGame: '🟠 Normal Mode',
                      descriptionGame: tr('focus_mode'),
                      iconGamePath: 'assets/icon/nomarl_ic.png',
                      backgroundColor: Color(0xFFf39c8c),
                      borderColor: Color(0xFFb45b4f),
                      gameMode: GameDifficulty.normal,
                      onTap: (gameMode) => _onNavigateGameScreen(gameMode),
                    ),
                    SizedBox(height: 16),
                    _GameMode(
                      titleGame: '🔵 Hard Mode',
                      descriptionGame: tr('hard_mode'),
                      iconGamePath: 'assets/icon/hard_ic.png',
                      backgroundColor: Color(0xFF87c2eb),
                      borderColor: Color(0xFF79a6bb),
                      gameMode: GameDifficulty.hard,
                      onTap: (gameMode) => _onNavigateGameScreen(gameMode),
                    ),
                    SizedBox(height: 16),
                    _GameMode(
                      titleGame: '🟣 Crazy Mode',
                      descriptionGame: tr('extreme_mode'),
                      iconGamePath: 'assets/icon/crazy_ic.png',
                      backgroundColor: Color(0xFF9b59b6),
                      borderColor: Color(0xFF6f2d91),
                      gameMode: GameDifficulty.crazy,
                      onTap: (gameMode) => _onNavigateGameScreen(gameMode),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ]),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
