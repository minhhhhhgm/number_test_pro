import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../service/test_board.dart';

class LeaderBoardScreen extends StatefulWidget {
  const LeaderBoardScreen({super.key});

  @override
  State<LeaderBoardScreen> createState() => _LeaderBoardScreenState();
}

class _LeaderBoardScreenState extends State<LeaderBoardScreen> {
  final _leaderboardService = GetIt.instance<LeaderBoardServiceTest>();
  Future<List<LeaderBoardModel>>? _leaderboardFuture;

  // Thông tin người chơi hiện tại để highlight
  String? _currentDeviceId;
  String? _currentPlayerName;

  TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initUserDataAndLoadLeaderboard();
  }

  // Hàm khởi tạo dữ liệu người dùng và tải leaderboard
  Future<void> _initUserDataAndLoadLeaderboard() async {
    _currentDeviceId = await _leaderboardService.getDeviceId();
    _currentPlayerName = await _leaderboardService.getPlayerName();
    print('_currentPlayerName $_currentPlayerName');
    _nameController.text = _currentPlayerName ?? ''; // Hiển thị tên nếu đã có

    _loadLeaderboard(); // Tải leaderboard sau khi có thông tin người dùng
  }

  // Hàm tải leaderboard
  Future<void> _loadLeaderboard() async {
    setState(() {
      _leaderboardFuture = _leaderboardService.getTop10Leaderboard();
    });
  }

  // Hàm để đặt tên người chơi
  Future<void> _setPlayerName() async {
    final newName = _nameController.text.trim();
    if (newName.isEmpty) {
      _showSnackBar('Tên không được để trống.', Colors.red);
      return;
    }
    try {
      await _leaderboardService.setPlayerName(newName: newName);
      _currentPlayerName = newName; // Cập nhật tên cục bộ
      _showSnackBar('Đặt tên thành công!', Colors.green);
      _loadLeaderboard(); // Tải lại leaderboard sau khi đặt tên
    } on Exception catch (e) {
      _showSnackBar(e.toString().replaceFirst('Exception: ', ''), Colors.red);
    }
  }

  // Hàm để cập nhật điểm cao nhất (ví dụ: mô phỏng điểm mới)
  Future<void> _updatePlayerScore() async {
    if (_currentPlayerName == null || _currentPlayerName!.isEmpty) {
      _showSnackBar('Vui lòng đặt tên trước khi cập nhật điểm.', Colors.orange);
      return;
    }
    final randomScore =
        Random().nextInt(10000) + 1; // Điểm ngẫu nhiên từ 1 đến 10000
    try {
      await _leaderboardService.updateHighScore(score: randomScore);
      _showSnackBar('Cập nhật điểm $randomScore thành công!', Colors.green);
      _loadLeaderboard(); // Tải lại leaderboard
    } on Exception catch (e) {
      _showSnackBar(e.toString().replaceFirst('Exception: ', ''), Colors.red);
    }
  }

  // Hàm để tạo dữ liệu mock (chỉ dùng khi test)
  Future<void> _uploadMockData() async {
    try {
      await _leaderboardService.uploadMockTestData();
      _showSnackBar('Đã tạo và đẩy dữ liệu mock!', Colors.green);
      _loadLeaderboard(); // Tải lại leaderboard sau khi mock
    } catch (e) {
      _showSnackBar('Lỗi khi tạo dữ liệu mock: $e', Colors.red);
    }
  }

  // Hàm để xóa dữ liệu test (chỉ dùng khi test)
  Future<void> _cleanUpTestData() async {
    try {
      await _leaderboardService.cleanUpTestData();
      _currentPlayerName = null; // Reset tên sau khi xóa
      _nameController.clear(); // Xóa text trong TextField
      _showSnackBar('Đã xóa toàn bộ dữ liệu test!', Colors.green);
      _loadLeaderboard(); // Tải lại leaderboard (sẽ trống)
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
        title: const Text('Leader Board'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadLeaderboard,
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'mock_data') {
                _uploadMockData();
              } else if (value == 'clean_data') {
                _cleanUpTestData();
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem<String>(
                  value: 'mock_data',
                  child: Text('Tạo & Đẩy Mock Data'),
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
          // Phần đặt tên người chơi và cập nhật điểm
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Tên người chơi',
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.check_circle),
                      onPressed: _setPlayerName,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _updatePlayerScore,
                  child: const Text('Cập nhật điểm ngẫu nhiên'),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),

          // FutureBuilder cho Leaderboard
          Expanded(
            child: FutureBuilder<List<LeaderBoardModel>>(
              future: _leaderboardFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Lỗi: ${snapshot.error}'));
                } else {
                  // Dù có lỗi hay không có data, vẫn cố gắng hiển thị trạng thái
                  final List<LeaderBoardModel> leaderboard =
                      snapshot.data ?? [];

                  LeaderBoardModel? currentUserEntry;
                  // Danh sách top 10 players KHÔNG bao gồm người chơi hiện tại
                  List<LeaderBoardModel> top10ExcludingCurrentUser = [];

                  // Tách người chơi hiện tại ra và xây dựng danh sách top 10
                  for (var player in leaderboard) {
                    if (player.id == _currentDeviceId) {
                      currentUserEntry = player;
                    } else {
                      if (top10ExcludingCurrentUser.length < 10) {
                        // Giới hạn 10 người
                        top10ExcludingCurrentUser.add(player);
                      }
                    }
                  }

                  // Sort lại danh sách để đảm bảo rank chính xác
                  top10ExcludingCurrentUser
                      .sort((a, b) => b.highScore.compareTo(a.highScore));
                  // Gán lại rank sau khi sort (vì hàm getTop10Leaderboard đã gán rank tạm thời)
                  for (int i = 0; i < top10ExcludingCurrentUser.length; i++) {
                    top10ExcludingCurrentUser[i].rank = i + 1;
                  }

                  // Kiểm tra nếu người chơi hiện tại nằm trong top 10 của danh sách gốc
                  // nhưng không phải là người đang được tách ra riêng.
                  // Đây là phần hơi phức tạp nếu bạn muốn highlight người chơi trong danh sách top 10 chính
                  // và cũng có mục riêng cho họ.
                  // Hiện tại, logic sẽ luôn hiển thị mục riêng nếu có currentUserEntry.

                  // Nếu không có dữ liệu nào (cả top 10 và người chơi hiện tại), hiển thị _buildEmptyLeaderboardState
                  if (leaderboard.isEmpty &&
                      currentUserEntry == null &&
                      _currentPlayerName == null) {
                    return _buildEmptyLeaderboardState(); // Chỉ hiển thị nếu không có gì cả
                  }

                  return Column(
                    children: [
                      // Hiển thị Top 3 từ danh sách đã lọc (nếu có đủ)
                      _buildTop3Section(
                          top10ExcludingCurrentUser.take(3).toList()),

                      // Danh sách các người chơi còn lại trong Top 10 (từ rank 4 trở đi)
                      Expanded(
                        child: ListView.builder(
                          itemCount:
                              max(0, top10ExcludingCurrentUser.length - 3),
                          itemBuilder: (context, index) {
                            final player = top10ExcludingCurrentUser[index + 3];
                            // Không cần highlight ở đây vì người chơi hiện tại sẽ ở phần riêng
                            return _buildLeaderboardItem(player, false);
                          },
                        ),
                      ),

                      // Hiển thị vị trí của người chơi hiện tại
                      // Luôn hiển thị section này nếu có thông tin người chơi hiện tại (currentUserEntry)
                      // Nó sẽ tự động highlight và hiển thị rank chính xác hoặc "N/A"
                      if (currentUserEntry != null)
                        _buildCurrentUserSection(currentUserEntry),
                      if (_currentPlayerName != null &&
                          _currentPlayerName!.isNotEmpty)
                        // Nếu chưa có điểm trong DB nhưng đã có tên local
                        _buildCurrentUserSection(LeaderBoardModel(
                          id: _currentDeviceId!,
                          name: _currentPlayerName!,
                          highScore: 0,
                          lastUpdated: DateTime.now().millisecondsSinceEpoch,
                          rank: -1, // No Rank
                        )),
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
      children: [
        const SizedBox(height: 50),
        const Icon(Icons.leaderboard_outlined, size: 80, color: Colors.grey),
        const Text('Chưa có dữ liệu leaderboard.',
            style: TextStyle(fontSize: 18, color: Colors.grey)),
        const SizedBox(height: 20),
        if (_currentPlayerName != null && _currentPlayerName!.isNotEmpty)
          _buildCurrentUserSection(LeaderBoardModel(
            // Tạo một mock model cho người chơi hiện tại
            id: _currentDeviceId!,
            name: _currentPlayerName!,
            highScore: 0,
            lastUpdated: DateTime.now().millisecondsSinceEpoch,
            rank: -1, // No Rank
          )),
        const Text('Hãy cập nhật điểm để xuất hiện trên bảng xếp hạng!',
            style: TextStyle(fontSize: 16, color: Colors.grey)),
      ],
    );
  }

  Widget _buildLeaderboardItem(LeaderBoardModel player, bool isCurrentUser) {
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
                  player.rank == -1 ? 'N/A' : '#${player.rank}',
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
            CircleAvatar(
              backgroundColor: isCurrentUser
                  ? Colors.lightBlue.shade300
                  : Colors.amber.shade200,
              child: Text(
                player.name.isNotEmpty ? player.name[0].toUpperCase() : '?',
                style: const TextStyle(color: Colors.brown),
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

  Widget _buildTop3Section(List<LeaderBoardModel> players) {
    // Lấy 3 người chơi đầu tiên, đảm bảo có ít nhất 3 vị trí để tránh lỗi index
    final List<LeaderBoardModel?> top3 = List.generate(
        3, (index) => index < players.length ? players[index] : null);

    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.deepPurple.shade50,
      child: Column(
        children: [
          const Text(
            '🏆 TOP PLAYERS 🏆',
            style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildTopPlayerColumn(
                player: top3[1],
                rank: 2,
                height: 120,
                color: Colors.brown.shade400,
              ),
              _buildTopPlayerColumn(
                player: top3[0],
                rank: 1,
                height: 150,
                color: Colors.green.shade600,
                isWinner: true,
              ),
              _buildTopPlayerColumn(
                player: top3[2],
                rank: 3,
                height: 100,
                color: Colors.orange.shade600,
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildTopPlayerColumn({
    required LeaderBoardModel? player,
    required int rank,
    required double height,
    required Color color,
    bool isWinner = false,
  }) {
    final bool isCurrentUser = player != null && player.id == _currentDeviceId;

    return Column(
      children: [
        if (isWinner)
          const Icon(Icons.emoji_events, color: Colors.amber, size: 36),
        CircleAvatar(
          radius: 30,
          backgroundColor: isCurrentUser
              ? Colors.lightBlue.shade300
              : color.withOpacity(0.7),
          child: Text(
            player?.name.isNotEmpty == true
                ? player!.name[0].toUpperCase()
                : '?',
            style: const TextStyle(fontSize: 24, color: Colors.white),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 80,
          height: height,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
            border: isCurrentUser
                ? Border.all(color: Colors.lightBlue, width: 3)
                : Border.all(color: color, width: 0),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '#$rank',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
              if (player != null) ...[
                Text(
                  player.name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${player.highScore} pts',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ] else ...[
                const Text('...', style: TextStyle(color: Colors.white70)),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCurrentUserSection(LeaderBoardModel currentUserEntry) {
    final bool isNoRank = currentUserEntry.rank == -1;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      margin: const EdgeInsets.only(top: 8, bottom: 16, left: 16, right: 16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade300, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Vị trí của bạn:',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87),
          ),
          const SizedBox(height: 8),
          _buildLeaderboardItem(currentUserEntry, true), // Luôn highlight ở đây
          if (isNoRank)
            const Padding(
              padding: EdgeInsets.only(top: 8.0, left: 16.0),
              child: Text(
                'Bạn chưa có thứ hạng trong bảng xếp hạng. Hãy chơi để đạt điểm cao!',
                style:
                    TextStyle(fontStyle: FontStyle.italic, color: Colors.red),
              ),
            ),
        ],
      ),
    );
  }
}
