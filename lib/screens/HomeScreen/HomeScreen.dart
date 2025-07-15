import 'package:flutter/material.dart';
import 'package:numbers/component/LeaderboardCard.dart';
import 'package:numbers/component/RecentScoreCard.dart';
import 'package:numbers/service/SoundService.dart';
import 'package:numbers/store/BestScoreStore.dart';
import 'package:numbers/store/SettingsStore.dart';
import 'appTitle.widget.dart';
import 'bestScore.widget.dart';
import 'tutorialBtn.widget.dart';
import 'widgets/StatsOverviewCard.dart';
import 'widgets/DailyStreakCard.dart';
import 'widgets/GameModesGrid.dart';
import 'widgets/QuickActionsCard.dart';
import '../SettingScreen/SettingScreen.dart';
import '../GameScreen/GameScreen.dart';
import '../AchievementScreen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final SoundService _soundService = SoundService();
  final BestScoreStore _bestScoreStore = BestScoreStore();

  int _bestScore = 0;
  String _userName = '';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final bestScore = await _bestScoreStore.getBestScore();
      final userName = await SettingsStore.instance.getKey('name') ?? '';
      setState(() {
        _bestScore = bestScore;
        _userName = userName;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple.shade50,
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.games, color: Colors.white),
            SizedBox(width: 8),
            Text('Number Match'),
          ],
        ),
        backgroundColor: Colors.deepPurple,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () async {
              await _soundService.playButtonClick();
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => SettingScreen()),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: _loading
            ? Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: <Widget>[
                    // Header section
                    Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.deepPurple,
                            Colors.deepPurple.shade300,
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                      child: Column(
                        children: [
                          titleWiget(),
                          SizedBox(height: 16),
                          Text(
                            'Xin chào, ${_userName.isNotEmpty ? _userName : 'Người chơi'}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 8),
                          buildBestScore(_bestScore),
                        ],
                      ),
                    ),

                    // Daily streak card
                    DailyStreakCard(),

                    // Stats overview
                    StatsOverviewCard(),

                    // Quick actions
                    QuickActionsCard(),

                    // Game modes
                    GameModesGrid(),

                    // Tutorial button
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: TutorialWidget(),
                    ),

                    // Leaderboards
                    Container(
                      margin: EdgeInsets.only(top: 16),
                      child: Column(
                        children: [
                          LeaderboardCard(
                              title: "Today's Leaders",
                              type: 'daily',
                              limit: 6),
                          LeaderboardCard(
                              title: "Leaders for Week",
                              type: 'weekly',
                              limit: 6),
                          LeaderboardCard(
                              title: "All-Time Leaders",
                              type: 'overall',
                              limit: 6),
                          RecentScoreBoard(),
                        ],
                      ),
                    ),

                    // Bottom padding for FAB
                    SizedBox(height: 80),
                  ],
                ),
              ),
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.deepPurple.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: () async {
            await _soundService.playButtonClick();
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => GameScreen(gameMode: 'classic'),
              ),
            );
          },
          icon: Icon(Icons.play_arrow, color: Colors.white),
          label: Text(
            'CHƠI NGAY',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          backgroundColor: Colors.deepPurple,
          elevation: 0,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
