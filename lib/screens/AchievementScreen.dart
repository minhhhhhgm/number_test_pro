import 'package:flutter/material.dart';
import 'package:numbers/service/AchievementService.dart';
import 'package:numbers/service/SoundService.dart';
import 'package:numbers/service/ShareService.dart';
import 'package:numbers/schema/Achievement.dart';

class AchievementScreen extends StatefulWidget {
  @override
  _AchievementScreenState createState() => _AchievementScreenState();
}

class _AchievementScreenState extends State<AchievementScreen> {
  final AchievementService _achievementService = AchievementService();
  final SoundService _soundService = SoundService();
  List<Achievement> _achievements = [];
  Map<String, int> _stats = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await _achievementService.initialize();
    setState(() {
      _achievements = _achievementService.achievements;
      _stats = _achievementService.stats;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Thành tích'),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            icon: Icon(Icons.share),
            onPressed: () async {
              await _soundService.playButtonClick();
              _shareAchievements();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildStatsCard(),
            SizedBox(height: 16),
            _buildAchievementsList(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCard() {
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.deepPurple.shade100, Colors.deepPurple.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '📊 Thống kê tổng quan',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple.shade800,
            ),
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem('🎮 Tổng màn chơi', _stats['total_games']?.toString() ?? '0'),
              ),
              Expanded(
                child: _buildStatItem('🏆 Chiến thắng', _stats['total_wins']?.toString() ?? '0'),
              ),
            ],
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildStatItem('🔥 Chuỗi tốt nhất', _stats['best_streak']?.toString() ?? '0'),
              ),
              Expanded(
                child: _buildStatItem('📈 Điểm cao nhất', _stats['best_score']?.toString() ?? '0'),
              ),
            ],
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildStatItem('🗓️ Ngày liên tiếp', _stats['consecutive_days']?.toString() ?? '0'),
              ),
              Expanded(
                child: _buildStatItem('🎯 Daily challenges', _stats['daily_challenges_completed']?.toString() ?? '0'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple.shade700,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.deepPurple.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            '🏅 Thành tích (${_achievementService.unlockedAchievements.length}/${_achievements.length})',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple.shade800,
            ),
          ),
        ),
        SizedBox(height: 8),
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: _achievements.length,
          itemBuilder: (context, index) {
            Achievement achievement = _achievements[index];
            return _buildAchievementCard(achievement);
          },
        ),
      ],
    );
  }

  Widget _buildAchievementCard(Achievement achievement) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: achievement.isUnlocked ? Colors.green.shade50 : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: achievement.isUnlocked ? Colors.green.shade200 : Colors.grey.shade300,
          width: 1,
        ),
      ),
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: achievement.isUnlocked ? Colors.green.shade100 : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(25),
          ),
          child: Center(
            child: Text(
              achievement.icon,
              style: TextStyle(fontSize: 24),
            ),
          ),
        ),
        title: Text(
          achievement.title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: achievement.isUnlocked ? Colors.green.shade800 : Colors.grey.shade600,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              achievement.description,
              style: TextStyle(
                color: achievement.isUnlocked ? Colors.green.shade600 : Colors.grey.shade500,
              ),
            ),
            SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: LinearProgressIndicator(
                    value: achievement.progressPercentage,
                    backgroundColor: Colors.grey.shade300,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      achievement.isUnlocked ? Colors.green : Colors.blue,
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Text(
                  '${achievement.progress}/${achievement.maxProgress}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (achievement.isUnlocked)
              Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 24,
              ),
            Text(
              '${achievement.reward}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.orange.shade700,
              ),
            ),
            Text(
              'coin',
              style: TextStyle(
                fontSize: 10,
                color: Colors.orange.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _shareAchievements() async {
    await ShareService().shareAchievements();
  }
} 