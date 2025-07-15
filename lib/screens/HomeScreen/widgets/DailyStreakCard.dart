import 'package:flutter/material.dart';
import 'package:numbers/service/AchievementService.dart';

class DailyStreakCard extends StatefulWidget {
  @override
  _DailyStreakCardState createState() => _DailyStreakCardState();
}

class _DailyStreakCardState extends State<DailyStreakCard> {
  final AchievementService _achievementService = AchievementService();
  int _consecutiveDays = 0;
  int _lastPlayDate = 0;

  @override
  void initState() {
    super.initState();
    _loadStreakData();
  }

  Future<void> _loadStreakData() async {
    await _achievementService.initialize();
    setState(() {
      _consecutiveDays = _achievementService.consecutiveDays;
      _lastPlayDate = _achievementService.stats['last_play_date'] ?? 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    bool hasPlayedToday = _hasPlayedToday();
    
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: hasPlayedToday 
            ? [Colors.green.shade100, Colors.green.shade50]
            : [Colors.orange.shade100, Colors.orange.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: hasPlayedToday ? Colors.green.shade200 : Colors.orange.shade200,
          width: 2,
        ),
      ),
      child: Row(
        children: [
          // Streak icon and count
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: hasPlayedToday ? Colors.green.shade200 : Colors.orange.shade200,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    hasPlayedToday ? Icons.local_fire_department : Icons.whatshot,
                    color: hasPlayedToday ? Colors.green.shade700 : Colors.orange.shade700,
                    size: 24,
                  ),
                  Text(
                    '$_consecutiveDays',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: hasPlayedToday ? Colors.green.shade700 : Colors.orange.shade700,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: 16),
          
          // Streak info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hasPlayedToday ? '🔥 Hôm nay đã chơi!' : '🔥 Chưa chơi hôm nay',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: hasPlayedToday ? Colors.green.shade800 : Colors.orange.shade800,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Chuỗi: $_consecutiveDays ngày liên tiếp',
                  style: TextStyle(
                    fontSize: 14,
                    color: hasPlayedToday ? Colors.green.shade600 : Colors.orange.shade600,
                  ),
                ),
                SizedBox(height: 8),
                
                // Progress to next milestone
                _buildMilestoneProgress(),
              ],
            ),
          ),
          
          // Action button
          if (!hasPlayedToday)
            Container(
              decoration: BoxDecoration(
                color: Colors.orange.shade600,
                borderRadius: BorderRadius.circular(20),
              ),
              child: IconButton(
                icon: Icon(Icons.play_arrow, color: Colors.white),
                onPressed: () {
                  // Navigate to game
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMilestoneProgress() {
    int nextMilestone = _getNextMilestone();
    double progress = _consecutiveDays / nextMilestone;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Tiến tới $nextMilestone ngày',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade700,
              ),
            ),
            Text(
              '$_consecutiveDays/$nextMilestone',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        SizedBox(height: 4),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.grey.shade300,
          valueColor: AlwaysStoppedAnimation<Color>(
            _hasPlayedToday() ? Colors.green : Colors.orange,
          ),
        ),
      ],
    );
  }

  int _getNextMilestone() {
    if (_consecutiveDays < 3) return 3;
    if (_consecutiveDays < 7) return 7;
    if (_consecutiveDays < 14) return 14;
    if (_consecutiveDays < 30) return 30;
    return _consecutiveDays + 7; // Next week milestone
  }

  bool _hasPlayedToday() {
    int today = DateTime.now().millisecondsSinceEpoch ~/ (1000 * 60 * 60 * 24);
    return _lastPlayDate == today;
  }
} 