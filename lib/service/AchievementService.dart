import 'package:numbers/schema/Achievement.dart';
import 'package:numbers/service/SoundService.dart';
import 'package:numbers/store/SettingsStore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AchievementService {
  static final AchievementService _instance = AchievementService._internal();
  factory AchievementService() => _instance;
  AchievementService._internal();

  late SharedPreferences _prefs;
  bool _initialized = false;
  List<Achievement> _achievements = [];
  Map<String, int> _stats = {};

  // Stats keys
  static const String _totalGames = 'total_games';
  static const String _totalWins = 'total_wins';
  static const String _totalLosses = 'total_losses';
  static const String _currentStreak = 'current_streak';
  static const String _bestStreak = 'best_streak';
  static const String _totalScore = 'total_score';
  static const String _bestScore = 'best_score';
  static const String _totalPlayTime = 'total_play_time';
  static const String _fastestWin = 'fastest_win';
  static const String _powerUpsUsed = 'power_ups_used';
  static const String _hintsUsed = 'hints_used';
  static const String _dailyChallengesCompleted = 'daily_challenges_completed';
  static const String _consecutiveDays = 'consecutive_days';
  static const String _lastPlayDate = 'last_play_date';
  static const String _sharesCount = 'shares_count';
  static const String _perfectGames = 'perfect_games';
  static const String _nightGames = 'night_games';
  static const String _weekendGames = 'weekend_games';
  static const String _fastGames = 'fast_games';
  static const String _hintlessGames = 'hintless_games';

  Future<void> initialize() async {
    if (_initialized) return;
    
    _prefs = await SharedPreferences.getInstance();
    _achievements = Achievement.getAllAchievements();
    await _loadStats();
    await _loadAchievements();
    _initialized = true;
  }

  // Load stats from SharedPreferences
  Future<void> _loadStats() async {
    _stats = {
      _totalGames: _prefs.getInt(_totalGames) ?? 0,
      _totalWins: _prefs.getInt(_totalWins) ?? 0,
      _totalLosses: _prefs.getInt(_totalLosses) ?? 0,
      _currentStreak: _prefs.getInt(_currentStreak) ?? 0,
      _bestStreak: _prefs.getInt(_bestStreak) ?? 0,
      _totalScore: _prefs.getInt(_totalScore) ?? 0,
      _bestScore: _prefs.getInt(_bestScore) ?? 0,
      _totalPlayTime: _prefs.getInt(_totalPlayTime) ?? 0,
      _fastestWin: _prefs.getInt(_fastestWin) ?? 999,
      _powerUpsUsed: _prefs.getInt(_powerUpsUsed) ?? 0,
      _hintsUsed: _prefs.getInt(_hintsUsed) ?? 0,
      _dailyChallengesCompleted: _prefs.getInt(_dailyChallengesCompleted) ?? 0,
      _consecutiveDays: _prefs.getInt(_consecutiveDays) ?? 0,
      _lastPlayDate: _prefs.getInt(_lastPlayDate) ?? 0,
      _sharesCount: _prefs.getInt(_sharesCount) ?? 0,
      _perfectGames: _prefs.getInt(_perfectGames) ?? 0,
      _nightGames: _prefs.getInt(_nightGames) ?? 0,
      _weekendGames: _prefs.getInt(_weekendGames) ?? 0,
      _fastGames: _prefs.getInt(_fastGames) ?? 0,
      _hintlessGames: _prefs.getInt(_hintlessGames) ?? 0,
    };
  }

  // Save stats to SharedPreferences
  Future<void> _saveStats() async {
    for (var entry in _stats.entries) {
      await _prefs.setInt(entry.key, entry.value);
    }
  }

  // Load achievements from SharedPreferences
  Future<void> _loadAchievements() async {
    String? achievementsJson = _prefs.getString('achievements');
    if (achievementsJson != null) {
      List<dynamic> achievementsList = json.decode(achievementsJson);
      for (int i = 0; i < achievementsList.length; i++) {
        Map<String, dynamic> achievementData = achievementsList[i];
        _achievements[i] = _achievements[i].copyWith(
          isUnlocked: achievementData['isUnlocked'] ?? false,
          unlockedAt: achievementData['unlockedAt'] != null 
            ? DateTime.parse(achievementData['unlockedAt']) 
            : null,
          progress: achievementData['progress'] ?? 0,
        );
      }
    }
  }

  // Save achievements to SharedPreferences
  Future<void> _saveAchievements() async {
    List<Map<String, dynamic>> achievementsList = _achievements.map((achievement) => {
      'isUnlocked': achievement.isUnlocked,
      'unlockedAt': achievement.unlockedAt?.toIso8601String(),
      'progress': achievement.progress,
    }).toList();
    
    await _prefs.setString('achievements', json.encode(achievementsList));
  }

  // Game events
  Future<void> onGameStart() async {
    await initialize();
    _stats[_totalGames] = (_stats[_totalGames] ?? 0) + 1;
    await _updateConsecutiveDays();
    await _saveStats();
  }

  Future<void> onGameWin({
    required int score,
    required int timeLeft,
    required bool usedHints,
    required int powerUpsUsed,
  }) async {
    await initialize();
    
    _stats[_totalWins] = (_stats[_totalWins] ?? 0) + 1;
    _stats[_currentStreak] = (_stats[_currentStreak] ?? 0) + 1;
    _stats[_totalScore] = (_stats[_totalScore] ?? 0) + score;
    
    if (score > (_stats[_bestScore] ?? 0)) {
      _stats[_bestScore] = score;
    }
    
    if (_stats[_currentStreak]! > (_stats[_bestStreak] ?? 0)) {
      _stats[_bestStreak] = _stats[_currentStreak]!;
    }

    // Update fastest win
    int gameTime = 60 - timeLeft; // Assuming 60 seconds game duration
    if (gameTime < (_stats[_fastestWin] ?? 999)) {
      _stats[_fastestWin] = gameTime;
    }

    // Update perfect games
    if (score >= 1000) {
      _stats[_perfectGames] = (_stats[_perfectGames] ?? 0) + 1;
    }

    // Update fast games
    if (gameTime <= 15) {
      _stats[_fastGames] = (_stats[_fastGames] ?? 0) + 1;
    }

    // Update hintless games
    if (!usedHints) {
      _stats[_hintlessGames] = (_stats[_hintlessGames] ?? 0) + 1;
    }

    // Update power ups used
    _stats[_powerUpsUsed] = (_stats[_powerUpsUsed] ?? 0) + powerUpsUsed;

    await _saveStats();
    await _checkAchievements();
  }

  Future<void> onGameLoss() async {
    await initialize();
    
    _stats[_totalLosses] = (_stats[_totalLosses] ?? 0) + 1;
    _stats[_currentStreak] = 0;
    
    await _saveStats();
  }

  Future<void> onHintUsed() async {
    await initialize();
    _stats[_hintsUsed] = (_stats[_hintsUsed] ?? 0) + 1;
    await _saveStats();
  }

  Future<void> onDailyChallengeCompleted() async {
    await initialize();
    _stats[_dailyChallengesCompleted] = (_stats[_dailyChallengesCompleted] ?? 0) + 1;
    await _saveStats();
    await _checkAchievements();
  }

  Future<void> onShare() async {
    await initialize();
    _stats[_sharesCount] = (_stats[_sharesCount] ?? 0) + 1;
    await _saveStats();
    await _checkAchievements();
  }

  Future<void> _updateConsecutiveDays() async {
    int today = DateTime.now().millisecondsSinceEpoch ~/ (1000 * 60 * 60 * 24);
    int lastPlayDate = _stats[_lastPlayDate] ?? 0;
    
    if (lastPlayDate == 0) {
      // First time playing
      _stats[_consecutiveDays] = 1;
    } else if (today - lastPlayDate == 1) {
      // Consecutive day
      _stats[_consecutiveDays] = (_stats[_consecutiveDays] ?? 0) + 1;
    } else if (today - lastPlayDate > 1) {
      // Break in streak
      _stats[_consecutiveDays] = 1;
    }
    
    _stats[_lastPlayDate] = today;
    
    // Check for night games (after 10 PM)
    int hour = DateTime.now().hour;
    if (hour >= 22) {
      _stats[_nightGames] = (_stats[_nightGames] ?? 0) + 1;
    }
    
    // Check for weekend games
    int weekday = DateTime.now().weekday;
    if (weekday == 6 || weekday == 7) { // Saturday or Sunday
      _stats[_weekendGames] = (_stats[_weekendGames] ?? 0) + 1;
    }
  }

  Future<void> _checkAchievements() async {
    List<Achievement> newlyUnlocked = [];
    
    for (int i = 0; i < _achievements.length; i++) {
      Achievement achievement = _achievements[i];
      if (achievement.isUnlocked) continue;
      
      bool shouldUnlock = false;
      int newProgress = 0;
      
      switch (achievement.type) {
        case AchievementType.firstWin:
          shouldUnlock = (_stats[_totalWins] ?? 0) >= 1;
          newProgress = _stats[_totalWins] ?? 0;
          break;
          
        case AchievementType.speedRunner:
          shouldUnlock = (_stats[_fastestWin] ?? 999) <= 10;
          newProgress = (_stats[_fastestWin] ?? 999) <= 10 ? 1 : 0;
          break;
          
        case AchievementType.perfectScore:
          shouldUnlock = (_stats[_perfectGames] ?? 0) >= 1;
          newProgress = _stats[_perfectGames] ?? 0;
          break;
          
        case AchievementType.streakMaster:
          newProgress = _stats[_bestStreak] ?? 0;
          shouldUnlock = newProgress >= 10;
          break;
          
        case AchievementType.dailyWarrior:
          newProgress = _stats[_consecutiveDays] ?? 0;
          shouldUnlock = newProgress >= 7;
          break;
          
        case AchievementType.powerUpUser:
          newProgress = (_stats[_powerUpsUsed] ?? 0) >= 4 ? 4 : (_stats[_powerUpsUsed] ?? 0);
          shouldUnlock = newProgress >= 4;
          break;
          
        case AchievementType.hintLess:
          shouldUnlock = (_stats[_hintlessGames] ?? 0) >= 1;
          newProgress = _stats[_hintlessGames] ?? 0;
          break;
          
        case AchievementType.comebackKing:
          // This will be checked in onGameWin with timeLeft parameter
          break;
          
        case AchievementType.targetHunter:
          newProgress = _stats[_totalWins] ?? 0;
          shouldUnlock = newProgress >= 100;
          break;
          
        case AchievementType.timeMaster:
          newProgress = _stats[_fastGames] ?? 0;
          shouldUnlock = newProgress >= 50;
          break;
          
        case AchievementType.dailyChampion:
          newProgress = _stats[_dailyChallengesCompleted] ?? 0;
          shouldUnlock = newProgress >= 30;
          break;
          
        case AchievementType.socialButterfly:
          newProgress = _stats[_sharesCount] ?? 0;
          shouldUnlock = newProgress >= 10;
          break;
          
        case AchievementType.perfectionist:
          newProgress = _stats[_bestStreak] ?? 0;
          shouldUnlock = newProgress >= 5;
          break;
          
        case AchievementType.earlyBird:
          newProgress = _stats[_consecutiveDays] ?? 0;
          shouldUnlock = newProgress >= 7;
          break;
          
        case AchievementType.nightOwl:
          newProgress = _stats[_nightGames] ?? 0;
          shouldUnlock = newProgress >= 5;
          break;
          
        case AchievementType.weekendWarrior:
          newProgress = _stats[_weekendGames] ?? 0;
          shouldUnlock = newProgress >= 5;
          break;
          
        case AchievementType.luckyStreak:
          // This will be checked in onGameWin with timeLeft parameter
          break;
          
        case AchievementType.powerPlayer:
          newProgress = _stats[_powerUpsUsed] ?? 0;
          shouldUnlock = newProgress >= 50;
          break;
          
        case AchievementType.hintMaster:
          newProgress = _stats[_hintlessGames] ?? 0;
          shouldUnlock = newProgress >= 20;
          break;
          
        case AchievementType.scoreChaser:
          shouldUnlock = (_stats[_bestScore] ?? 0) >= 1000;
          newProgress = (_stats[_bestScore] ?? 0) >= 1000 ? 1000 : (_stats[_bestScore] ?? 0);
          break;
      }
      
      if (shouldUnlock) {
        _achievements[i] = achievement.copyWith(
          isUnlocked: true,
          unlockedAt: DateTime.now(),
          progress: newProgress,
        );
        newlyUnlocked.add(_achievements[i]);
      } else if (newProgress > achievement.progress) {
        _achievements[i] = achievement.copyWith(progress: newProgress);
      }
    }
    
    if (newlyUnlocked.isNotEmpty) {
      await _saveAchievements();
      await SoundService().playAchievement();
      
      // Show achievement notification
      for (Achievement achievement in newlyUnlocked) {
        await _showAchievementNotification(achievement);
      }
    }
  }

  Future<void> _showAchievementNotification(Achievement achievement) async {
    // This will be implemented in UI layer
    print('🎉 Achievement Unlocked: ${achievement.title} - ${achievement.reward} coins!');
  }

  // Special achievement checks
  Future<void> checkComebackKing(int timeLeft) async {
    if (timeLeft < 5) {
      await _updateAchievementProgress(AchievementType.comebackKing, 1);
    }
  }

  Future<void> checkLuckyStreak(int gameTime) async {
    if (gameTime < 20) {
      await _updateAchievementProgress(AchievementType.luckyStreak, 1);
    }
  }

  Future<void> _updateAchievementProgress(AchievementType type, int progress) async {
    int index = _achievements.indexWhere((a) => a.type == type);
    if (index != -1) {
      Achievement achievement = _achievements[index];
      int newProgress = achievement.progress + progress;
      
      if (newProgress >= achievement.requirement && !achievement.isUnlocked) {
        _achievements[index] = achievement.copyWith(
          isUnlocked: true,
          unlockedAt: DateTime.now(),
          progress: newProgress,
        );
        await _saveAchievements();
        await SoundService().playAchievement();
        await _showAchievementNotification(_achievements[index]);
      } else if (newProgress > achievement.progress) {
        _achievements[index] = achievement.copyWith(progress: newProgress);
        await _saveAchievements();
      }
    }
  }

  // Getters
  List<Achievement> get achievements => _achievements;
  List<Achievement> get unlockedAchievements => _achievements.where((a) => a.isUnlocked).toList();
  List<Achievement> get lockedAchievements => _achievements.where((a) => !a.isUnlocked).toList();
  
  Map<String, int> get stats => Map.from(_stats);
  int get totalGames => _stats[_totalGames] ?? 0;
  int get totalWins => _stats[_totalWins] ?? 0;
  int get currentStreak => _stats[_currentStreak] ?? 0;
  int get bestStreak => _stats[_bestStreak] ?? 0;
  int get totalScore => _stats[_totalScore] ?? 0;
  int get bestScore => _stats[_bestScore] ?? 0;
  int get consecutiveDays => _stats[_consecutiveDays] ?? 0;
} 