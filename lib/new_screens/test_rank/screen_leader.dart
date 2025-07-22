// lib/screens/leaderboard_screen.dart
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:numbers/di/service_locator.dart';
import 'package:numbers/models/rank_model.dart';
import 'package:numbers/new_screens/test_rank/service.dart';

class ScreenLeader extends StatefulWidget {
  const ScreenLeader({super.key});

  @override
  State<ScreenLeader> createState() => _ScreenLeaderState();
}

class _ScreenLeaderState extends State<ScreenLeader> {
  final _leaderboardService = getIt<Service>();
  late Future<List<RankModel>> _leaderboardFuture =
      Future.value([]); // Giá trị khởi tạo
  String? _currentDeviceId;
  String? _currentPlayerName;

  TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initUserDataAndLoadLeaderboard();
  }

  Future<void> _initUserDataAndLoadLeaderboard() async {
    _currentDeviceId = await _leaderboardService.getDeviceId();
    _currentPlayerName = await _leaderboardService.getPlayerName();
    _nameController.text = _currentPlayerName ?? '';

    _loadLeaderboard();
  }

  Future<void> _loadLeaderboard() async {
    setState(() {
      _leaderboardFuture = _leaderboardService.getTop10Leaderboard();
    });
  }

  Future<void> _showSetNameDialog() async {
    _nameController.text = _currentPlayerName ?? '';
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Đặt tên người chơi'),
          content: TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              hintText: 'Nhập tên của bạn',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () async {
                final newName = _nameController.text.trim();
                if (newName.isEmpty) {
                  _showSnackBar('Tên không được để trống.', Colors.red);
                  return;
                }
                try {
                  await _leaderboardService.setPlayerName(
                      newName: newName, score: 0);
                  _currentPlayerName = newName;
                  _showSnackBar('Đặt tên thành công!', Colors.green);
                  Navigator.pop(context);
                  _loadLeaderboard();
                } on Exception catch (e) {
                  _showSnackBar(
                      e.toString().replaceFirst('Exception: ', ''), Colors.red);
                }
              },
              child: const Text('Xác nhận'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _updatePlayerScore() async {
    if (_currentPlayerName == null || _currentPlayerName!.isEmpty) {
      _showSnackBar('Vui lòng đặt tên trước khi cập nhật điểm.', Colors.orange);
      return;
    }
    final randomScore = Random().nextInt(10000) + 1;
    try {
      await _leaderboardService.updateHighScore(score: randomScore);
      _showSnackBar('Cập nhật điểm $randomScore thành công!', Colors.green);
      _loadLeaderboard();
    } on Exception catch (e) {
      _showSnackBar(e.toString().replaceFirst('Exception: ', ''), Colors.red);
    }
  }

  Future<void> _addMockPlayer(bool isCurrentPlayer) async {
    try {
      await _leaderboardService.addMockPlayer(isCurrentPlayer: isCurrentPlayer);
      _showSnackBar('Đã thêm người chơi mock!', Colors.green);
      if (isCurrentPlayer) {
        _currentPlayerName = await _leaderboardService.getPlayerName();
      }
      _loadLeaderboard();
    } catch (e) {
      _showSnackBar('Lỗi khi thêm người chơi mock: $e', Colors.red);
    }
  }

  Future<void> _cleanUpTestData() async {
    try {
      await _leaderboardService.cleanUpTestData();
      _currentPlayerName = null;
      _nameController.clear();
      _showSnackBar('Đã xóa toàn bộ dữ liệu test!', Colors.green);
      _loadLeaderboard();
    } catch (e) {
      _showSnackBar('Lỗi khi xóa dữ liệu: $e', Colors.red);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bảng Xếp Hạng'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadLeaderboard,
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'add_mock_current') {
                _addMockPlayer(true);
              } else if (value == 'add_mock_other') {
                _addMockPlayer(false);
              } else if (value == 'clean_data') {
                _cleanUpTestData();
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem<String>(
                  value: 'add_mock_current',
                  child: Text('Add Mock (Tôi)'),
                ),
                const PopupMenuItem<String>(
                  value: 'add_mock_other',
                  child: Text('Add Mock (Người khác)'),
                ),
                const PopupMenuItem<String>(
                  value: 'clean_data',
                  child: Text('Xóa Dữ liệu Test'),
                ),
              ];
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: _currentPlayerName == null || _currentPlayerName!.isEmpty
                ? Column(
                    children: [
                      const Text(
                        'Bạn chưa có tên trên bảng xếp hạng.',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: _showSetNameDialog,
                        child: const Text('Đua Rank Ngay!'),
                      ),
                    ],
                  )
                : Column(
                    children: [
                      Text(
                        'Tên của bạn: ${_currentPlayerName}',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      ElevatedButton(
                        onPressed: _updatePlayerScore,
                        child: const Text('Cập nhật điểm ngẫu nhiên'),
                      ),
                    ],
                  ),
          ),
          const Divider(),
          Expanded(
            child: FutureBuilder<List<RankModel>>(
              future: _leaderboardFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Lỗi: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return _buildEmptyLeaderboardState();
                } else {
                  final List<RankModel> leaderboard = snapshot.data!;
                  RankModel? currentUserEntry;

                  // Tìm người chơi hiện tại trong top 10
                  for (var player in leaderboard) {
                    if (player.id == _currentDeviceId) {
                      currentUserEntry = player;
                      break;
                    }
                  }

                  return Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          itemCount: leaderboard.length,
                          itemBuilder: (context, index) {
                            final player = leaderboard[index];
                            final bool isCurrentUser =
                                (currentUserEntry != null &&
                                    player.id == currentUserEntry.id);
                            return _buildLeaderboardItem(player, isCurrentUser);
                          },
                        ),
                      ),
                      if (currentUserEntry == null) Text('No Rank')
                    ],
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyLeaderboardState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.leaderboard_outlined, size: 80, color: Colors.grey),
        const SizedBox(height: 10),
        const Text(
          'Chưa có dữ liệu trên bảng xếp hạng.',
          style: TextStyle(fontSize: 18, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        if (_currentPlayerName != null && _currentPlayerName!.isNotEmpty)
          _buildNoRankPlayerItem(),
      ],
    );
  }

  Widget _buildNoRankPlayerItem() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 4,
      color: Colors.amber.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Colors.amber, width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            const SizedBox(
              width: 40,
              child: Center(
                child: Text(
                  'N/A', // No Rank
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _currentPlayerName!,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const Text(
                    'Bạn chưa có thứ hạng.',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.info_outline, color: Colors.red, size: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaderboardItem(RankModel player, bool isCurrentUser) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: isCurrentUser ? 8 : 2,
      color: isCurrentUser ? Colors.lightBlue.shade100 : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isCurrentUser
            ? const BorderSide(color: Colors.lightBlue, width: 2)
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            SizedBox(
              width: 40,
              child: Center(
                child: Text(
                  '#${player.rank}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isCurrentUser
                        ? Colors.lightBlue.shade800
                        : Colors.grey.shade700,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    player.name,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: isCurrentUser
                          ? Colors.lightBlue.shade800
                          : Colors.black87,
                    ),
                  ),
                  Text(
                    '${player.highScore} pts',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            if (isCurrentUser)
              const Icon(Icons.star, color: Colors.amber, size: 24),
          ],
        ),
      ),
    );
  }
}
