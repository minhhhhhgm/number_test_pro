import 'package:equatable/equatable.dart';

enum AchievementType {
  firstWin,           // Thắng lần đầu
  speedRunner,       // Hoàn thành < 10s
  perfectScore,      // Điểm tối đa
  streakMaster,      // 10 màn liên tiếp đúng
  dailyWarrior,      // Hoàn thành 7 ngày liên tiếp
  powerUpUser,       // Sử dụng tất cả power-up
  hintLess,          // Hoàn thành không dùng gợi ý
  comebackKing,      // Thắng với < 5s còn lại
  targetHunter,      // Hoàn thành 100 màn
  timeMaster,        // Hoàn thành 50 màn dưới 15s
  dailyChampion,     // Hoàn thành 30 daily challenges
  socialButterfly,   // Chia sẻ 10 lần
  perfectionist,     // 5 màn liên tiếp không sai
  earlyBird,         // Chơi 7 ngày liên tiếp
  nightOwl,          // Chơi sau 10h tối 5 ngày
  weekendWarrior,    // Chơi 5 ngày cuối tuần
  luckyStreak,       // 3 màn liên tiếp với < 20s
  powerPlayer,       // Sử dụng 50 power-ups
  hintMaster,        // Hoàn thành 20 màn không dùng hint
  scoreChaser,       // Đạt 1000 điểm trong 1 màn
}

class Achievement extends Equatable {
  final String id;
  final String title;
  final String description;
  final AchievementType type;
  final int requirement;
  final int reward;
  final String icon;
  final bool isUnlocked;
  final DateTime? unlockedAt;
  final int progress;
  final int maxProgress;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.requirement,
    required this.reward,
    required this.icon,
    this.isUnlocked = false,
    this.unlockedAt,
    this.progress = 0,
    required this.maxProgress,
  });

  Achievement copyWith({
    String? id,
    String? title,
    String? description,
    AchievementType? type,
    int? requirement,
    int? reward,
    String? icon,
    bool? isUnlocked,
    DateTime? unlockedAt,
    int? progress,
    int? maxProgress,
  }) {
    return Achievement(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      requirement: requirement ?? this.requirement,
      reward: reward ?? this.reward,
      icon: icon ?? this.icon,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      progress: progress ?? this.progress,
      maxProgress: maxProgress ?? this.maxProgress,
    );
  }

  double get progressPercentage => progress / maxProgress;

  static List<Achievement> getAllAchievements() {
    return [
      Achievement(
        id: 'first_win',
        title: 'Chiến thắng đầu tiên',
        description: 'Hoàn thành màn chơi đầu tiên',
        type: AchievementType.firstWin,
        requirement: 1,
        reward: 50,
        icon: '🏆',
        maxProgress: 1,
      ),
      Achievement(
        id: 'speed_runner',
        title: 'Tốc độ siêu đẳng',
        description: 'Hoàn thành màn chơi trong vòng 10 giây',
        type: AchievementType.speedRunner,
        requirement: 1,
        reward: 100,
        icon: '⚡',
        maxProgress: 1,
      ),
      Achievement(
        id: 'perfect_score',
        title: 'Điểm số hoàn hảo',
        description: 'Đạt điểm tối đa trong một màn chơi',
        type: AchievementType.perfectScore,
        requirement: 1,
        reward: 200,
        icon: '💎',
        maxProgress: 1,
      ),
      Achievement(
        id: 'streak_master',
        title: 'Bậc thầy chuỗi',
        description: 'Hoàn thành 10 màn liên tiếp không sai',
        type: AchievementType.streakMaster,
        requirement: 10,
        reward: 500,
        icon: '🔥',
        maxProgress: 10,
      ),
      Achievement(
        id: 'daily_warrior',
        title: 'Chiến binh hàng ngày',
        description: 'Hoàn thành thử thách 7 ngày liên tiếp',
        type: AchievementType.dailyWarrior,
        requirement: 7,
        reward: 300,
        icon: '🗓️',
        maxProgress: 7,
      ),
      Achievement(
        id: 'power_up_user',
        title: 'Người dùng power-up',
        description: 'Sử dụng tất cả loại power-up',
        type: AchievementType.powerUpUser,
        requirement: 4,
        reward: 150,
        icon: '⭐',
        maxProgress: 4,
      ),
      Achievement(
        id: 'hint_less',
        title: 'Tự lực cánh sinh',
        description: 'Hoàn thành màn chơi không dùng gợi ý',
        type: AchievementType.hintLess,
        requirement: 1,
        reward: 120,
        icon: '🧠',
        maxProgress: 1,
      ),
      Achievement(
        id: 'comeback_king',
        title: 'Vua comeback',
        description: 'Thắng với ít hơn 5 giây còn lại',
        type: AchievementType.comebackKing,
        requirement: 1,
        reward: 180,
        icon: '👑',
        maxProgress: 1,
      ),
      Achievement(
        id: 'target_hunter',
        title: 'Thợ săn mục tiêu',
        description: 'Hoàn thành 100 màn chơi',
        type: AchievementType.targetHunter,
        requirement: 100,
        reward: 1000,
        icon: '🎯',
        maxProgress: 100,
      ),
      Achievement(
        id: 'time_master',
        title: 'Bậc thầy thời gian',
        description: 'Hoàn thành 50 màn dưới 15 giây',
        type: AchievementType.timeMaster,
        requirement: 50,
        reward: 800,
        icon: '⏱️',
        maxProgress: 50,
      ),
      Achievement(
        id: 'daily_champion',
        title: 'Nhà vô địch hàng ngày',
        description: 'Hoàn thành 30 thử thách hàng ngày',
        type: AchievementType.dailyChampion,
        requirement: 30,
        reward: 1500,
        icon: '🏅',
        maxProgress: 30,
      ),
      Achievement(
        id: 'social_butterfly',
        title: 'Bướm xã hội',
        description: 'Chia sẻ thành tích 10 lần',
        type: AchievementType.socialButterfly,
        requirement: 10,
        reward: 200,
        icon: '🦋',
        maxProgress: 10,
      ),
      Achievement(
        id: 'perfectionist',
        title: 'Người hoàn hảo',
        description: '5 màn liên tiếp không sai',
        type: AchievementType.perfectionist,
        requirement: 5,
        reward: 400,
        icon: '✨',
        maxProgress: 5,
      ),
      Achievement(
        id: 'early_bird',
        title: 'Chim sớm',
        description: 'Chơi 7 ngày liên tiếp',
        type: AchievementType.earlyBird,
        requirement: 7,
        reward: 250,
        icon: '🐦',
        maxProgress: 7,
      ),
      Achievement(
        id: 'night_owl',
        title: 'Cú đêm',
        description: 'Chơi sau 10h tối 5 ngày',
        type: AchievementType.nightOwl,
        requirement: 5,
        reward: 300,
        icon: '🦉',
        maxProgress: 5,
      ),
      Achievement(
        id: 'weekend_warrior',
        title: 'Chiến binh cuối tuần',
        description: 'Chơi 5 ngày cuối tuần',
        type: AchievementType.weekendWarrior,
        requirement: 5,
        reward: 350,
        icon: '📅',
        maxProgress: 5,
      ),
      Achievement(
        id: 'lucky_streak',
        title: 'Chuỗi may mắn',
        description: '3 màn liên tiếp với ít hơn 20 giây',
        type: AchievementType.luckyStreak,
        requirement: 3,
        reward: 200,
        icon: '🍀',
        maxProgress: 3,
      ),
      Achievement(
        id: 'power_player',
        title: 'Người chơi power',
        description: 'Sử dụng 50 power-ups',
        type: AchievementType.powerPlayer,
        requirement: 50,
        reward: 600,
        icon: '💪',
        maxProgress: 50,
      ),
      Achievement(
        id: 'hint_master',
        title: 'Bậc thầy gợi ý',
        description: 'Hoàn thành 20 màn không dùng gợi ý',
        type: AchievementType.hintMaster,
        requirement: 20,
        reward: 400,
        icon: '🧩',
        maxProgress: 20,
      ),
      Achievement(
        id: 'score_chaser',
        title: 'Người đuổi điểm',
        description: 'Đạt 1000 điểm trong 1 màn',
        type: AchievementType.scoreChaser,
        requirement: 1000,
        reward: 1000,
        icon: '📊',
        maxProgress: 1000,
      ),
    ];
  }

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    type,
    requirement,
    reward,
    icon,
    isUnlocked,
    unlockedAt,
    progress,
    maxProgress,
  ];
} 