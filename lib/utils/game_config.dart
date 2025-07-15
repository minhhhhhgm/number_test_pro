class GameConfig {
  int blockSize;
  int minTarget;
  int maxTarget;
  int correctCombinationLength;
  int timePlay;

  GameConfig(
      {required this.blockSize,
      required this.minTarget,
      required this.maxTarget,
      required this.correctCombinationLength,
      required this.timePlay});

  void updateFromDifficulty(GameDifficulty difficulty) {
    final config = GameConfig.fromDifficulty(difficulty);
    blockSize = config.blockSize;
    minTarget = config.minTarget;
    maxTarget = config.maxTarget;
    correctCombinationLength = config.correctCombinationLength;
    timePlay = config.timePlay;
  }

  static GameConfig fromDifficulty(GameDifficulty difficulty) {
    switch (difficulty) {
      case GameDifficulty.easy:
        return GameConfig(
            blockSize: 6,
            minTarget: 5,
            maxTarget: 50,
            correctCombinationLength: 2,
            timePlay: 60);
      case GameDifficulty.normal:
        return GameConfig(
            blockSize: 9,
            minTarget: 50,
            maxTarget: 100,
            correctCombinationLength: 3,
            timePlay: 90);
      case GameDifficulty.hard:
        return GameConfig(
            blockSize: 12,
            minTarget: 10,
            maxTarget: 500,
            correctCombinationLength: 4,
            timePlay: 120);
      case GameDifficulty.crazy:
        return GameConfig(
            blockSize: 15,
            minTarget: 10,
            maxTarget: 1000,
            correctCombinationLength: 5,
            timePlay: 180);
    }
  }
}

enum GameDifficulty { easy, normal, hard, crazy }
