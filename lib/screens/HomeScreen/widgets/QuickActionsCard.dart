import 'package:flutter/material.dart';
import 'package:numbers/service/SoundService.dart';
import '../../AchievementScreen.dart';
import '../../SettingScreen/SettingScreen.dart';
import '../../GameScreen/GameScreen.dart';

class QuickActionsCard extends StatelessWidget {
  final SoundService _soundService = SoundService();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.indigo.shade100,
            Colors.indigo.shade50,
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
              Icon(Icons.flash_on, color: Colors.indigo.shade700, size: 24),
              SizedBox(width: 8),
              Text(
                'Thao tác nhanh',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo.shade800,
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          
          // Quick actions grid
          GridView.count(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            crossAxisCount: 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.1,
            children: [
              _buildQuickAction(
                context,
                '🏅 Thành tích',
                Icons.emoji_events,
                Colors.orange,
                () => _navigateToAchievements(context),
              ),
              _buildQuickAction(
                context,
                '⚙️ Cài đặt',
                Icons.settings,
                Colors.blue,
                () => _navigateToSettings(context),
              ),
              _buildQuickAction(
                context,
                '📊 Thống kê',
                Icons.analytics,
                Colors.green,
                () => _showStats(context),
              ),
              _buildQuickAction(
                context,
                '🎯 Daily',
                Icons.calendar_today,
                Colors.purple,
                () => _navigateToDailyChallenge(context),
              ),
              _buildQuickAction(
                context,
                '🏆 Leaderboard',
                Icons.leaderboard,
                Colors.red,
                () => _showLeaderboard(context),
              ),
              _buildQuickAction(
                context,
                '❓ Hướng dẫn',
                Icons.help,
                Colors.teal,
                () => _showTutorial(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAction(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () async {
            await _soundService.playButtonClick();
            onTap();
          },
          child: Padding(
            padding: EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 20,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToAchievements(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => AchievementScreen()),
    );
  }

  void _navigateToSettings(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => SettingScreen()),
    );
  }

  void _showStats(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('📊 Thống kê chi tiết'),
        content: Text('Tính năng này sẽ được phát triển trong phiên bản tiếp theo!'),
        actions: [
          TextButton(
            child: Text('OK'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void _navigateToDailyChallenge(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => GameScreen(gameMode: 'daily'),
      ),
    );
  }

  void _showLeaderboard(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('🏆 Bảng xếp hạng'),
        content: Text('Bảng xếp hạng đã có sẵn ở cuối trang chủ!'),
        actions: [
          TextButton(
            child: Text('OK'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void _showTutorial(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('❓ Hướng dẫn'),
        content: Text('Tính năng này sẽ được phát triển trong phiên bản tiếp theo!'),
        actions: [
          TextButton(
            child: Text('OK'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
} 