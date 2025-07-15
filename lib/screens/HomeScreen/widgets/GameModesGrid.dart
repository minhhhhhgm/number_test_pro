import 'package:flutter/material.dart';
import 'package:numbers/service/SoundService.dart';
import '../../GameScreen/GameScreen.dart';

class GameModesGrid extends StatelessWidget {
  final SoundService _soundService = SoundService();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.games, color: Colors.deepPurple.shade700, size: 24),
              SizedBox(width: 8),
              Text(
                'Chế độ chơi',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple.shade800,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          
          // Game modes grid
          GridView.count(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.2,
            children: [
              _buildGameModeCard(
                context,
                'Classic',
                'Chế độ cổ điển',
                Icons.flash_on,
                Colors.orange,
                'Chọn số để tạo thành tổng bằng target',
                () => _navigateToGame(context, 'classic'),
              ),
              _buildGameModeCard(
                context,
                'Endless',
                'Chế độ vô tận',
                Icons.all_inclusive,
                Colors.blue,
                'Chơi liên tục không giới hạn thời gian',
                () => _navigateToGame(context, 'endless'),
              ),
              _buildGameModeCard(
                context,
                'Challenge',
                'Thử thách',
                Icons.emoji_events,
                Colors.green,
                'Các màn chơi có độ khó cao',
                () => _navigateToGame(context, 'challenge'),
              ),
              _buildGameModeCard(
                context,
                'Daily',
                'Thử thách ngày',
                Icons.calendar_today,
                Colors.purple,
                'Thử thách đặc biệt mỗi ngày',
                () => _navigateToGame(context, 'daily'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGameModeCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color,
    String description,
    VoidCallback onTap,
  ) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, Colors.yellow],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.cyan, width: 1),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () async {
            await _soundService.playButtonClick();
            onTap();
          },
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Icon(
                    icon,
                    color: Colors.green,
                    size: 28,
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.green,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8),
                // Container(
                //   padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                //   decoration: BoxDecoration(
                //     color: Colors.green,
                //     borderRadius: BorderRadius.circular(12),
                //   ),
                //   child: Text(
                //     'CHƠI',
                //     style: TextStyle(
                //       fontSize: 10,
                //       fontWeight: FontWeight.bold,
                //       color: Colors.green,
                //     ),
                //   ),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToGame(BuildContext context, String mode) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => GameScreen(gameMode: mode),
      ),
    );
  }
} 