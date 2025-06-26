import 'package:shared_preferences/shared_preferences.dart';

class BestScoreStore {
  late SharedPreferences prefs;
  final String key = 'bestScore';
  init() async {
    prefs = await SharedPreferences.getInstance();
  }

  updateScore(int currentBest) async {
    int bestScore = await getBestScore();

    bestScore = bestScore > currentBest ? bestScore : currentBest;

    return await prefs.setInt(key, bestScore);
  }

  Future getBestScore() async {
    await init();
    return prefs.getInt(key) == null ? 0 : prefs.getInt(key);
  }
}
