import 'dart:ui';

class GameConfig {
  int blockSize;
  int minTarget;
  int maxTarget;
  int correctCombinationLength;
  int timePlay;
  GameDifficulty gameMode;
  int pointBonus;

  Color textColor,
      borderColor,
      backgroundColorCountDown,
      foregroundColorCountDown,
      backgroundColor;

  GameConfig(
      {required this.blockSize,
      required this.minTarget,
      required this.maxTarget,
      required this.correctCombinationLength,
      required this.timePlay,
      required this.textColor,
      required this.borderColor,
      required this.backgroundColorCountDown,
      required this.foregroundColorCountDown,
      required this.backgroundColor,
      required this.gameMode,
      required this.pointBonus});

  void updateFromDifficulty(GameDifficulty difficulty) {
    final config = GameConfig.fromDifficulty(difficulty);
    blockSize = config.blockSize;
    minTarget = config.minTarget;
    maxTarget = config.maxTarget;
    correctCombinationLength = config.correctCombinationLength;
    timePlay = config.timePlay;
    textColor = config.textColor;
    borderColor = config.borderColor;
    backgroundColorCountDown = config.backgroundColorCountDown;
    foregroundColorCountDown = config.foregroundColorCountDown;
    backgroundColor = config.backgroundColor;
    gameMode = config.gameMode;
    pointBonus = config.pointBonus;
  }

  static GameConfig fromDifficulty(GameDifficulty difficulty) {
    switch (difficulty) {
      case GameDifficulty.chill:
        return GameConfig(
          blockSize: 6,
          minTarget: 5,
          maxTarget: 50,
          correctCombinationLength: 2,
          timePlay: 60,
          textColor: const Color(0xFF4A665A),
          borderColor: const Color(0xFFA7C4B5),
          backgroundColorCountDown: const Color(0xFFC8E6C9),
          foregroundColorCountDown: const Color(0xFF81C784),
          backgroundColor: const Color(0xFFF0FDF6),
          gameMode: GameDifficulty.chill,
          pointBonus: 1,
        );

      case GameDifficulty.easy:
        return GameConfig(
            blockSize: 6,
            minTarget: 5,
            maxTarget: 50,
            correctCombinationLength: 2,
            timePlay: 60,
            textColor: const Color(0xFF647c29),
            borderColor: const Color(0xFFbecaa1),
            backgroundColorCountDown: const Color(0xFF637c27),
            foregroundColorCountDown: const Color(0xFF96e94d),
            backgroundColor: Color(0xFFe9fab5),
            gameMode: GameDifficulty.easy,
            pointBonus: 1);
      case GameDifficulty.normal:
        return GameConfig(
            blockSize: 9,
            minTarget: 50,
            maxTarget: 100,
            correctCombinationLength: 3,
            timePlay: 90,
            textColor: const Color(0xFF5e3417), // darker của border
            borderColor: const Color(0xFF91521f),
            backgroundColorCountDown: const Color(0xFFd97a2f),
            foregroundColorCountDown: const Color(0xFFf5ad77),
            backgroundColor: Color(0xFFFFE5CD),
            gameMode: GameDifficulty.normal,
            pointBonus: 2);
      case GameDifficulty.hard:
        return GameConfig(
            blockSize: 12,
            minTarget: 10,
            maxTarget: 500,
            correctCombinationLength: 4,
            timePlay: 120,
            textColor: const Color(0xFF3c5d6c), // darker của border
            borderColor: const Color(0xFF79a6bb),
            backgroundColorCountDown: const Color(0xFF99cfe8),
            foregroundColorCountDown: const Color(0xFF4e8faa),
            backgroundColor: Color(0xFFe4f4fb),
            gameMode: GameDifficulty.hard,
            pointBonus: 4);
      case GameDifficulty.crazy:
        return GameConfig(
            blockSize: 15,
            minTarget: 10,
            maxTarget: 1000,
            correctCombinationLength: 5,
            timePlay: 180,
            textColor: const Color(0xFF4e2b68),
            borderColor: const Color(0xFF6f2d91),
            backgroundColorCountDown: const Color(0xFFb47edc),
            foregroundColorCountDown: const Color(0xFFcba1e6),
            backgroundColor: Color(0xFFf0e3f9),
            gameMode: GameDifficulty.crazy,
            pointBonus: 10);
    }
  }
}

enum GameDifficulty { chill, easy, normal, hard, crazy }
