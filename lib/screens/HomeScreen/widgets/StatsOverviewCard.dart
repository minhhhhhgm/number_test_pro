import 'package:flutter/material.dart';
import 'package:numbers/service/AchievementService.dart';

class StatsOverviewCard extends StatefulWidget {
  @override
  _StatsOverviewCardState createState() => _StatsOverviewCardState();
}

class _StatsOverviewCardState extends State<StatsOverviewCard> {
  final AchievementService _achievementService = AchievementService();
  Map<String, int> _stats = {};

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    await _achievementService.initialize();
    setState(() {
      _stats = _achievementService.stats;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.deepPurple.shade100,
            Colors.deepPurple.shade50,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.analytics, color: Colors.deepPurple.shade700, size: 24),
              SizedBox(width: 8),
              Text(
                'Thống kê tổng quan',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple.shade800,
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          
          // First row - Key stats
          Row(
            children: [
              Expanded(child: _buildStatItem('🎮', 'Màn chơi', _stats['total_games']?.toString() ?? '0')),
              Expanded(child: _buildStatItem('🏆', 'Chiến thắng', _stats['total_wins']?.toString() ?? '0')),
              Expanded(child: _buildStatItem('🔥', 'Chuỗi tốt nhất', _stats['best_streak']?.toString() ?? '0')),
            ],
          ),
          SizedBox(height: 16),
          
          // Second row - Progress stats
          Row(
            children: [
              Expanded(child: _buildStatItem('📈', 'Điểm cao nhất', _stats['best_score']?.toString() ?? '0')),
              Expanded(child: _buildStatItem('🗓️', 'Ngày liên tiếp', _stats['consecutive_days']?.toString() ?? '0')),
              Expanded(child: _buildStatItem('🎯', 'Daily challenges', _stats['daily_challenges_completed']?.toString() ?? '0')),
            ],
          ),
          SizedBox(height: 20),
          
          // Progress bars
          _buildProgressSection(),
        ],
      ),
    );
  }

  Widget _buildStatItem(String icon, String label, String value) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: Column(
        children: [
          Text(
            icon,
            style: TextStyle(fontSize: 24),
          ),
          SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple.shade700,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: Colors.deepPurple.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildProgressSection() {
    int totalAchievements = _achievementService.achievements.length;
    int unlockedAchievements = _achievementService.unlockedAchievements.length;
    double achievementProgress = totalAchievements > 0 ? unlockedAchievements / totalAchievements : 0;
    
    int totalGames = _stats['total_games'] ?? 0;
    int totalWins = _stats['total_wins'] ?? 0;
    double winRate = totalGames > 0 ? totalWins / totalGames : 0;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tiến độ',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.deepPurple.shade800,
          ),
        ),
        SizedBox(height: 12),
        
        // Achievement progress
        Row(
          children: [
            Icon(Icons.emoji_events, size: 16, color: Colors.orange.shade700),
            SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Thành tích',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                      ),
                      Text(
                        '$unlockedAchievements/$totalAchievements',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: achievementProgress,
                    backgroundColor: Colors.grey.shade300,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        
        // Win rate progress
        Row(
          children: [
            Icon(Icons.trending_up, size: 16, color: Colors.green.shade700),
            SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Tỷ lệ thắng',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                      ),
                      Text(
                        '${(winRate * 100).toStringAsFixed(1)}%',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: winRate,
                    backgroundColor: Colors.grey.shade300,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
} 