import 'dart:convert';
import 'package:numbers/service/RecentScoreService.dart';
import 'package:numbers/utils/Config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RecentScoreStore {
  late SharedPreferences prefs;

  final String scoreKey = 'recentScore';
  final maxStoreLength = maxKeepGameHistoryCount;

  init() async {
    prefs = await SharedPreferences.getInstance();
  }

  updateRecentScore(int score) async {
    await init();

    List recentScores = await getRecentScore();

    RecentScore newScore = RecentScore.manualPush(
        score.toString(), DateTime.now().millisecondsSinceEpoch.toString());

    recentScores.insert(0, newScore);

    if (recentScores.length > maxStoreLength) {
      recentScores.removeLast();
    }

    return await prefs.setString(scoreKey, json.encode(recentScores));
  }

  Future getRecentScore() async {
    await init();
    String? recentScores = prefs.getString(scoreKey);
    return recentScores == null ? [] : recentScoreFromJson(recentScores);
  }
}
