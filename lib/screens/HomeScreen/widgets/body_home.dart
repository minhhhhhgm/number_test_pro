import 'package:flutter/material.dart';

class BodyHome extends StatelessWidget {
  final String userName;
  final int userRank;
  final int totalPlayers;
  final int streakCount;
  final int gamesToday;
  final List<LeaderboardUser> leaderboard;
  final VoidCallback onPlay;
  final VoidCallback? onRefresh;
  final bool loading;

  const BodyHome({
    Key? key,
    required this.userName,
    required this.userRank,
    required this.totalPlayers,
    required this.streakCount,
    required this.gamesToday,
    required this.leaderboard,
    required this.onPlay,
    this.onRefresh,
    this.loading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final top3 = leaderboard.take(3).toList();
    final others = leaderboard.length > 3 ? leaderboard.sublist(3) : [];
    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: () async {},
          child: loading
              ? Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.only(bottom: 100),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header
                      _HeaderUserRank(
                        name: userName,
                        rank: userRank,
                        totalPlayers: totalPlayers,
                      ),
                      SizedBox(height: 16),
                      // Streak & Games Today
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(child: _StreakCard(streakCount: streakCount)),
                          SizedBox(width: 12),
                          Expanded(child: _GamesTodayCard(gamesToday: gamesToday)),
                        ],
                      ),
                      SizedBox(height: 24),
                      // Podium top 3
                      _LeaderboardPodium(top3: top3),
                      // List các user còn lại
                      if (others.isNotEmpty) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Text('Bảng xếp hạng', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        ),
                        ListView.separated(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: others.length,
                          separatorBuilder: (_, __) => Divider(height: 1),
                          itemBuilder: (context, idx) {
                            final user = others[idx];
                            return ListTile(
                              leading: Text('${idx + 4}', style: TextStyle(fontWeight: FontWeight.bold)),
                              title: Text(user.name, style: TextStyle(fontWeight: FontWeight.w500)),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.star, color: Colors.amber, size: 18),
                                  SizedBox(width: 4),
                                  Text(user.score.toString(), style: TextStyle(fontWeight: FontWeight.bold)),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                      SizedBox(height: 100),
                    ],
                  ),
                ),
        ),
        // Floating Play Button
        Positioned(
          left: 0,
          right: 0,
          bottom: 24,
          child: Center(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: Colors.deepPurple.withOpacity(0.3),
                    blurRadius: 16,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: FloatingActionButton.extended(
                onPressed: onPlay,
                icon: Icon(Icons.play_arrow, color: Colors.white, size: 28),
                label: Text('CHƠI NGAY', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 18)),
                backgroundColor: Colors.deepPurple,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _HeaderUserRank extends StatelessWidget {
  final String name;
  final int rank;
  final int totalPlayers;
  const _HeaderUserRank({required this.name, required this.rank, required this.totalPlayers});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.deepPurple, Colors.deepPurple.shade300],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurple.withOpacity(0.15),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.account_circle, color: Colors.white, size: 32),
              SizedBox(width: 12),
              Text(name, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
            ],
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Icon(Icons.emoji_events, color: Colors.amberAccent, size: 20),
                SizedBox(width: 6),
                Text('Hạng $rank/$totalPlayers', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StreakCard extends StatelessWidget {
  final int streakCount;
  const _StreakCard({required this.streakCount});
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: Colors.orange.shade50,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
        child: Column(
          children: [
            Icon(Icons.local_fire_department, color: Colors.orange, size: 32),
            SizedBox(height: 6),
            Text('Chuỗi ngày', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.orange.shade800)),
            SizedBox(height: 2),
            Text('$streakCount', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: Colors.orange.shade900)),
          ],
        ),
      ),
    );
  }
}

class _GamesTodayCard extends StatelessWidget {
  final int gamesToday;
  const _GamesTodayCard({required this.gamesToday});
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
        child: Column(
          children: [
            Icon(Icons.videogame_asset, color: Colors.blue, size: 32),
            SizedBox(height: 6),
            Text('Game hôm nay', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.blue.shade800)),
            SizedBox(height: 2),
            Text('$gamesToday', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: Colors.blue.shade900)),
          ],
        ),
      ),
    );
  }
}

class _LeaderboardPodium extends StatelessWidget {
  final List<LeaderboardUser> top3;
  const _LeaderboardPodium({required this.top3});
  @override
  Widget build(BuildContext context) {
    // Đảm bảo có đủ 3 user, nếu thiếu thì dùng user rỗng
    final List<LeaderboardUser> podium = List.generate(3, (i) => i < top3.length ? top3[i] : LeaderboardUser.empty(rank: i+1));
    final heights = [120.0, 150.0, 100.0]; // 2nd, 1st, 3rd
    final colors = [Colors.grey, Colors.amber, Colors.brown];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (int i = 0; i < 3; i++)
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  AnimatedContainer(
                    duration: Duration(milliseconds: 400),
                    height: heights[i],
                    child: Stack(
                      alignment: Alignment.topCenter,
                      children: [
                        Container(
                          margin: EdgeInsets.only(top: 24),
                          decoration: BoxDecoration(
                            color: colors[i].withOpacity(0.15),
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: colors[i].withOpacity(0.18),
                                blurRadius: 8,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          height: heights[i] - 24,
                          width: 80,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              SizedBox(height: 32),
                              Text(
                                podium[i].name,
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: colors[i].shade800),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 2),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.star, color: colors[i], size: 18),
                                  SizedBox(width: 4),
                                  Text(
                                    podium[i].score.toString(),
                                    style: TextStyle(fontWeight: FontWeight.bold, color: colors[i].shade900),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                            ],
                          ),
                        ),
                        Positioned(
                          top: 0,
                          child: CircleAvatar(
                            radius: 28,
                            backgroundColor: Colors.white,
                            child: podium[i].avatarUrl != null && podium[i].avatarUrl!.isNotEmpty
                                ? ClipOval(
                                    child: Image.network(podium[i].avatarUrl!, width: 48, height: 48, fit: BoxFit.cover),
                                  )
                                : Icon(Icons.account_circle, size: 48, color: colors[i]),
                          ),
                        ),
                        Positioned(
                          top: 0,
                          right: 0,
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: colors[i],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              i == 0 ? '🥈' : i == 1 ? '🥇' : '🥉',
                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class LeaderboardUser {
  final String name;
  final int score;
  final int rank;
  final String? avatarUrl;
  LeaderboardUser({required this.name, required this.score, required this.rank, this.avatarUrl});
  factory LeaderboardUser.empty({required int rank}) => LeaderboardUser(name: '—', score: 0, rank: rank, avatarUrl: null);
} 