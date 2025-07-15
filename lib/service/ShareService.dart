import 'package:share_plus/share_plus.dart';
import 'package:numbers/service/AchievementService.dart';

class ShareService {
  static final ShareService _instance = ShareService._internal();
  factory ShareService() => _instance;
  ShareService._internal();

  Future<void> shareScore(int score, int bestScore, int totalGames) async {
    String shareText = '''
🎮 Number Match - Điểm số của tôi!

📊 Điểm hiện tại: $score
🎯 Điểm cao nhất: $bestScore
🎮 Tổng màn chơi: $totalGames

Tải ngay Number Match để thử thách bản thân! 🚀
    ''';
    
    await Share.share(shareText, subject: 'Number Match - Điểm số của tôi!');
  }

  Future<void> shareAchievements() async {
    final achievementService = AchievementService();
    await achievementService.initialize();
    
    int unlockedCount = achievementService.unlockedAchievements.length;
    int totalCount = achievementService.achievements.length;
    int totalScore = achievementService.totalScore;
    int bestScore = achievementService.bestScore;
    int bestStreak = achievementService.bestStreak;
    
    String shareText = '''
🎮 Number Match - Thành tích của tôi!

🏆 Đã mở khóa: $unlockedCount/$totalCount thành tích
📊 Tổng điểm: $totalScore
🎯 Điểm cao nhất: $bestScore
🔥 Chuỗi tốt nhất: $bestStreak

Tải ngay Number Match để thử thách bản thân! 🚀
    ''';
    
    await Share.share(shareText, subject: 'Number Match - Thành tích của tôi!');
  }

  Future<void> shareDailyChallenge(int score, String challengeDescription) async {
    String shareText = '''
🎯 Number Match - Thử thách ngày!

${challengeDescription}
📊 Điểm số: $score

Tải ngay Number Match để tham gia thử thách! 🚀
    ''';
    
    await Share.share(shareText, subject: 'Number Match - Thử thách ngày!');
  }

  Future<void> shareStreak(int currentStreak, int bestStreak) async {
    String shareText = '''
🔥 Number Match - Chuỗi chiến thắng!

🔥 Chuỗi hiện tại: $currentStreak
🏆 Chuỗi tốt nhất: $bestStreak

Tải ngay Number Match để thử thách bản thân! 🚀
    ''';
    
    await Share.share(shareText, subject: 'Number Match - Chuỗi chiến thắng!');
  }

  Future<void> sharePerfectGame(int score, int timeLeft) async {
    String shareText = '''
💎 Number Match - Màn chơi hoàn hảo!

💎 Điểm số: $score
⏱️ Thời gian còn lại: ${timeLeft}s

Tải ngay Number Match để thử thách bản thân! 🚀
    ''';
    
    await Share.share(shareText, subject: 'Number Match - Màn chơi hoàn hảo!');
  }
} 