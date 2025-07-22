import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:numbers/di/service_locator.dart';
import 'package:numbers/models/leader_board_model.dart';
import 'package:numbers/service/main_store_service.dart';
import 'package:uuid/uuid.dart';

class LeaderBoardService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Uuid _uuid = Uuid();
  final _scoreService = getIt<MainStoreService>();

  final String _overallCollection = 'user_leaderboard_overall';
  final String _weeklyCollection = 'user_leaderboard_weekly';
  final String _dailyCollection = 'user_leaderboard_daily';
  final String _monthlyCollection = 'user_leaderboard_monthly';
  final String _usernamesCollection = 'usernames';

  Future<String> getDeviceId() async {
    String? deviceId = await _scoreService.getKey(key: 'deviceId');
    if (deviceId == null || deviceId.isEmpty) {
      deviceId = _uuid.v4();
      await _scoreService.setKey(key: 'deviceId', data: deviceId);
    }
    return deviceId;
  }

  Future<String?> _getPlayerName() async {
    return await _scoreService.getKey(key: 'name');
  }

  Future<String?> getPlayerNameFromLocalStore() async {
    return await _scoreService.getKey(key: 'name');
  }

  Future<bool> isUsernameAvailable(String username) async {
    final usernameDocRef =
        _firestore.collection(_usernamesCollection).doc(username.toLowerCase());
    final docSnapshot = await usernameDocRef.get();
    return !docSnapshot.exists;
  }

  int getStartOfDayTimestamp(DateTime date) {
    return DateTime(date.year, date.month, date.day).millisecondsSinceEpoch;
  }

  int getStartOfWeekTimestamp(DateTime date) {
    final dayOfWeek = date.weekday;
    final daysToSubtract = dayOfWeek == 7 ? 6 : dayOfWeek - 1;
    final startOfWeekDate = date.subtract(Duration(days: daysToSubtract));
    return getStartOfDayTimestamp(startOfWeekDate);
  }

  int getStartOfMonthTimestamp(DateTime date) {
    return DateTime(date.year, date.month, 1).millisecondsSinceEpoch;
  }

  // THÊM MỚI: Hàm để thiết lập tên người chơi (duy nhất)
  Future<bool> setPlayerName({required String newName}) async {
    final deviceId = await getDeviceId();
    final oldName =
        await _scoreService.getKey(key: 'name'); // Lấy tên cũ nếu có
    final String lowercaseNewName = newName.toLowerCase();

    print(
        '\n--- Đang cố gắng thiết lập tên: "$newName" (DeviceId: $deviceId) ---');

    try {
      await _firestore.runTransaction((transaction) async {
        // 1. Kiểm tra tài liệu trong collection 'usernames' với tên mới (viết thường)
        final newUsernameDocRef =
            _firestore.collection(_usernamesCollection).doc(lowercaseNewName);
        final newUsernameSnapshot = await transaction.get(newUsernameDocRef);

        if (newUsernameSnapshot.exists) {
          // Nếu tài liệu tồn tại, tên này đã được sử dụng.
          // Kiểm tra xem nó có phải là của chính người dùng này không.
          final existingUserId =
              newUsernameSnapshot.data()?['userId'] as String?;
          if (existingUserId == deviceId) {
            // Tên này đã là của người dùng hiện tại, coi là thành công.
            print(
                '  ℹ️ Tên "$newName" đã là của người dùng hiện tại ($deviceId).');
            return; // Thoát khỏi transaction
          } else {
            // Tên đã được người khác sử dụng, ném lỗi để transaction thất bại
            print(
                '  ❌ Tên "$newName" đã được người khác sử dụng ($existingUserId).');
            throw Exception(
                'Tên người dùng đã tồn tại. Vui lòng chọn tên khác.');
          }
        }

        // 2. Nếu có tên cũ, xóa đăng ký tên cũ khỏi collection 'usernames'
        if (oldName != null && oldName.isNotEmpty) {
          final String lowercaseOldName = oldName.toLowerCase();
          final oldUsernameDocRef =
              _firestore.collection(_usernamesCollection).doc(lowercaseOldName);
          final oldUsernameSnapshot = await transaction.get(oldUsernameDocRef);

          // Chỉ xóa tên cũ nếu nó thuộc về chính deviceId này (để tránh xóa nhầm tên của người khác)
          if (oldUsernameSnapshot.exists &&
              oldUsernameSnapshot.data()?['userId'] == deviceId) {
            transaction.delete(oldUsernameDocRef);
            print('  ✅ Đã xóa đăng ký tên cũ: "$oldName"');
          }
        }

        // 3. Đăng ký tên mới trong collection 'usernames'
        transaction.set(newUsernameDocRef, {
          'isUsed': true,
          'userId': deviceId, // Liên kết tên với deviceId
          'timestamp': FieldValue.serverTimestamp(),
        });
        print('  ✅ Đã đăng ký tên mới trong _usernamesCollection: "$newName"');

        // 4. Cập nhật tên trong tài liệu người dùng chính (trong overall leaderboard)
        final userDocRef =
            _firestore.collection(_overallCollection).doc(deviceId);
        transaction.set(
            userDocRef,
            {
              'name': newName,
              'lastUpdated': FieldValue
                  .serverTimestamp(), // Dùng serverTimestamp cho nhất quán
            },
            SetOptions(merge: true)); // Merge để chỉ cập nhật trường name
        print(
            '  ✅ Đã cập nhật tên trong tài liệu người dùng chính (overall): "$newName"');
      });

      // 5. Nếu transaction thành công, lưu tên vào local store
      await _scoreService.setKey(key: 'name', data: newName);
      print('  ✅ Đã lưu tên mới cục bộ: "$newName"');
      return true;
    } catch (e) {
      print('  ❌ Lỗi khi thiết lập tên người chơi: $e');
      return false; // Transaction thất bại
    }
  }

  Future<void> updateHighScore({
    required int score,
    required int correctAnswers,
    required int totalQuestions,
    DateTime? customTime, // Cho phép truyền thời gian tùy chỉnh để test
  }) async {
    final deviceId = await getDeviceId();
    final playerName = await _getPlayerName();

    if (playerName == null || playerName.isEmpty) {
      print("❗ Lỗi: Người chơi chưa có tên. Không thể cập nhật điểm.");
      return; // Dừng việc cập nhật điểm nếu không có tên
    }
    final now = customTime ?? DateTime.now();
    final currentTimestamp = now.millisecondsSinceEpoch;

    final todayStart = getStartOfDayTimestamp(now);
    final weekStart = getStartOfWeekTimestamp(now);
    final monthStart = getStartOfMonthTimestamp(now);

    Map<String, dynamic> newHighScoreData = {
      'name': playerName,
      'highScore': score,
      'lastUpdated': currentTimestamp,
      'correctAnswers': correctAnswers,
      'totalQuestions': totalQuestions,
      'deviceId': deviceId,
    };

    print(
        "\n--- Cập nhật điểm mới: $score của $playerName lúc ${DateTime.fromMillisecondsSinceEpoch(currentTimestamp)} ---");

    // --- Cập nhật Overall Leaderboard ---
    await _firestore
        .collection(_overallCollection)
        .doc(deviceId)
        .set(
          newHighScoreData,
          SetOptions(merge: true),
        )
        .then((_) {
      print('  ✅ Đã cập nhật Overall Leaderboard cho $playerName: $score điểm');
    }).catchError((e) {
      print("  ❌ Lỗi cập nhật Overall Leaderboard: $e");
    });

    // --- Cập nhật Daily Leaderboard ---
    await _updatePeriodicLeaderboard(
      collectionRef: _firestore.collection(_dailyCollection),
      deviceId: deviceId,
      newScore: score,
      newHighScoreData: {
        ...newHighScoreData,
        'periodStartTimestamp': todayStart,
      },
      periodStartTimestamp: todayStart,
      periodName: 'Daily',
    );

    // --- Cập nhật Weekly Leaderboard ---
    await _updatePeriodicLeaderboard(
      collectionRef: _firestore.collection(_weeklyCollection),
      deviceId: deviceId,
      newScore: score,
      newHighScoreData: {
        ...newHighScoreData,
        'periodStartTimestamp': weekStart,
      },
      periodStartTimestamp: weekStart,
      periodName: 'Weekly',
    );

    // --- Cập nhật Monthly Leaderboard ---
    await _updatePeriodicLeaderboard(
      collectionRef: _firestore.collection(_monthlyCollection),
      deviceId: deviceId,
      newScore: score,
      newHighScoreData: {
        ...newHighScoreData,
        'periodStartTimestamp': monthStart,
      },
      periodStartTimestamp: monthStart,
      periodName: 'Monthly',
    );
  }

  Future<void> _updatePeriodicLeaderboard({
    required CollectionReference collectionRef,
    required String deviceId,
    required int newScore,
    required Map<String, dynamic> newHighScoreData,
    required int periodStartTimestamp,
    required String periodName,
  }) async {
    await _firestore.runTransaction((transaction) async {
      final docRef = collectionRef.doc(deviceId);
      final snapshot = await transaction.get(docRef);

      final existingData = snapshot.data() as Map<String, dynamic>?;

      if (!snapshot.exists ||
          existingData?['periodStartTimestamp'] != periodStartTimestamp) {
        transaction.set(docRef, newHighScoreData);
        print(
            '  ✅ Đã khởi tạo/cập nhật $periodName Leaderboard cho $newScore điểm.');
      } else {
        final currentHighScore = existingData?['highScore'] as int? ?? 0;
        if (newScore > currentHighScore) {
          transaction.update(docRef, {
            'highScore': newScore,
            'lastUpdated': newHighScoreData['lastUpdated'],
            'correctAnswers': newHighScoreData['correctAnswers'],
            'totalQuestions': newHighScoreData['totalQuestions'],
          });
          print(
              '  ✅ Đã cập nhật $periodName Leaderboard cho $newScore điểm (cao hơn ${currentHighScore}).');
        } else {
          print(
              '  ℹ️ Điểm mới ($newScore) không cao hơn điểm hiện tại ($currentHighScore) trong $periodName Leaderboard.');
        }
      }
    }).catchError((e) {
      print("  ❌ Lỗi trong transaction cập nhật $periodName Leaderboard: $e");
    });
  }

  Future<List<LeaderBoardModel>> getTop10Leaderboard({
    required String leaderboardType,
    int limit = 10,
  }) async {
    String collectionPath;
    int? periodStartTimestamp; // Chỉ cần cho các loại daily/weekly/monthly

    final now = DateTime.now(); // THÊM MỚI: Lấy thời gian hiện tại một lần

    switch (leaderboardType) {
      case 'overall':
        collectionPath = _overallCollection;
        break;
      case 'daily':
        collectionPath = _dailyCollection;
        // THAY ĐỔI: Chỉ lấy leaderboard của ngày hiện tại
        periodStartTimestamp = getStartOfDayTimestamp(now);
        break;
      case 'weekly':
        collectionPath = _weeklyCollection;
        // THAY ĐỔI: Chỉ lấy leaderboard của tuần hiện tại
        periodStartTimestamp = getStartOfWeekTimestamp(now);
        break;
      case 'monthly':
        collectionPath = _monthlyCollection;
        // THAY ĐỔI: Chỉ lấy leaderboard của tháng hiện tại
        periodStartTimestamp = getStartOfMonthTimestamp(now);
        break;
      default:
        print("Loại leaderboard không hợp lệ: $leaderboardType");
        return [];
    }

    try {
      Query query = _firestore.collection(collectionPath);

      // THÊM MỚI: Áp dụng điều kiện WHERE cho các leaderboard theo thời gian
      if (periodStartTimestamp != null) {
        query = query.where('periodStartTimestamp',
            isEqualTo: periodStartTimestamp);
      }

      final QuerySnapshot querySnapshot =
          await query.orderBy('highScore', descending: true).limit(limit).get();

      List<LeaderBoardModel> resultList = [];
      int rank = 1;
      for (var doc in querySnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        // THAY ĐỔI: LeaderBoardModel.fromMap cần id của document
        resultList.add(LeaderBoardModel.fromMap(data, doc.id)..rank = rank++);
      }

      // THÊM MỚI: Xử lý người chơi hiện tại (highlight hoặc 'No Rank')
      final currentDeviceId = await getDeviceId();
      final currentUserName =
          await _getPlayerName(); // Lấy tên người dùng hiện tại

      // Chỉ xử lý nếu người dùng có deviceId và tên
      if (currentUserName != null && currentUserName.isNotEmpty) {
        // Kiểm tra xem người chơi hiện tại đã có trong top N chưa
        bool isInTopN = resultList.any((e) => e.id == currentDeviceId);

        if (!isInTopN) {
          // Người chơi hiện tại không nằm trong top N, thử tìm vị trí chính xác của họ
          final currentUserDoc = await _firestore
              .collection(collectionPath)
              .doc(currentDeviceId)
              .get();

          if (currentUserDoc.exists) {
            final userData = currentUserDoc.data() as Map<String, dynamic>;
            // Cần tìm số lượng người chơi có điểm cao hơn để xác định rank chính xác
            Query countHigherQuery = _firestore
                .collection(collectionPath)
                .where('highScore', isGreaterThan: userData['highScore']);

            // THÊM MỚI: Đảm bảo điều kiện periodStartTimestamp cũng được áp dụng cho truy vấn đếm
            if (periodStartTimestamp != null) {
              countHigherQuery = countHigherQuery.where('periodStartTimestamp',
                  isEqualTo: periodStartTimestamp);
            }

            // THAY ĐỔI: Sử dụng .count() để lấy số lượng document hiệu quả hơn
            // Nếu bạn dùng phiên bản Firebase cũ hơn không có .count(), bạn sẽ phải dùng .get().then((s) => s.docs.length)
            final higherScoreSnapshot = await countHigherQuery.count().get();
            final currentUserRank = (higherScoreSnapshot.count ?? 0) + 1;

            // THAY ĐỔI: Tạo LeaderBoardModel cho người chơi hiện tại
            final currentUserLeaderboardModel =
                LeaderBoardModel.fromMap(userData, currentDeviceId)
                  ..rank = currentUserRank; // Gán rank vào model

            resultList.add(currentUserLeaderboardModel);
            // Lưu ý: Việc thêm vào cuối danh sách này chỉ mang tính hiển thị tạm thời
            // Logic UI cần phân biệt rõ top N và người chơi hiện tại,
            // ví dụ: đặt người chơi hiện tại vào một ô riêng biệt ở cuối danh sách hoặc hiển thị "No Rank" nếu rank > limit.
          } else {
            // THÊM MỚI: Nếu tài liệu của người chơi hiện tại không tồn tại trong leaderboard này (chưa có điểm)
            // Thêm một entry 'No Rank'
            resultList.add(LeaderBoardModel(
              id: currentDeviceId,
              name: currentUserName,
              highScore: 0, // Hoặc điểm hiện tại nếu bạn lưu ở đâu đó
              correctAnswers: 0,
              totalQuestions: 0,
              lastUpdated: DateTime.now().millisecondsSinceEpoch,
              rank:
                  -1, // Dùng -1 để biểu thị "No Rank" hoặc không có rank trong top
            ));
          }
        }
      }

      return resultList;
    } catch (e) {
      print("❌ Lỗi khi lấy leaderboard $leaderboardType: $e");
      return [];
    }
  }

  Future<void> cleanUpTestCollections() async {
    print("\n--- Đang xóa các collection test ---");
    final collections = [
      _overallCollection,
      _weeklyCollection,
      _dailyCollection,
      _monthlyCollection,
    ];

    for (var colName in collections) {
      print("  Đang xóa collection: $colName...");
      final snapshot = await _firestore.collection(colName).get();
      if (snapshot.docs.isEmpty) {
        print("  Không có document nào để xóa trong $colName.");
        continue;
      }
      final batch = _firestore.batch();
      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
      print("  ✅ Đã xóa ${snapshot.docs.length} document từ $colName.");
    }
    print("--- Hoàn tất xóa các collection test ---");
    // Xóa deviceId và name trong SettingsStore để giả lập người chơi mới cho lần chạy sau
    await getIt<MainStoreService>().setKey(key: 'deviceId', data: '');
    await getIt<MainStoreService>().setKey(key: 'name', data: '');
  }

  // THÊM MỚI: Hàm để tạo và đẩy dữ liệu mock lên Firestore
  // CHỈ DÙNG CHO MÔI TRƯỜNG PHÁT TRIỂN/KIỂM THỬ!
  Future<void> generateAndUploadMockDataToFirestore({
    int numberOfOverallPlayers = 30,
    int numberOfDailyPlayers = 20,
    int numberOfWeeklyPlayers = 25,
    int numberOfMonthlyPlayers = 28,
  }) async {
    print("\n--- Bắt đầu tạo và đẩy dữ liệu mock lên Firestore ---");

    final String currentDeviceId = await getDeviceId(); // Lấy deviceId trước

    // **BƯỚC QUAN TRỌNG: ĐẢM BẢO NGƯỜI CHƠI HIỆN TẠI CÓ TÊN HỢP LỆ**
    String? currentUserName =
        await _getPlayerName(); // Lấy tên hiện tại từ local storage
    if (currentUserName == null || currentUserName.trim().isEmpty) {
      // Nếu tên chưa có hoặc rỗng, đặt một tên mặc định VÀ LƯU NÓ VÀO FIRESTORE/LOCAL
      final String defaultMockName = 'Player_${_uuid.v4().substring(0, 6)}';
      print(
          '  Người chơi hiện tại chưa có tên hoặc tên rỗng. Đang thiết lập tên mặc định: "$defaultMockName"');
      // Gọi setPlayerName để lưu tên vào Firestore (usernames & overall) và local storage
      bool nameSetSuccessfully = await setPlayerName(newName: defaultMockName);
      if (!nameSetSuccessfully) {
        print(
            "  ❌ Lỗi: Không thể thiết lập tên mặc định cho người chơi hiện tại. Dừng tạo mock data.");
        return; // Dừng nếu không thể thiết lập tên
      }
      currentUserName =
          defaultMockName; // Cập nhật biến với tên đã được thiết lập
    }
    // Đến đây, currentUserName chắc chắn là một chuỗi không rỗng và đã được lưu.

    final int currentUserScore =
        1500; // Giả sử điểm của người dùng hiện tại để test vị trí

    // Bước 1: Dọn dẹp các collection hiện có trước khi thêm mới (tùy chọn nhưng nên làm)
    await cleanUpTestCollections();
    print("Đã dọn dẹp các collection cũ.");

    // Hàm nội bộ để tạo mock LeaderBoardModel
    List<LeaderBoardModel> _generateLocalMockData({
      required int count,
      required String prefix,
      int? periodStartTimestamp,
      int baseScore = 1000,
      int scoreDecrement = 50,
      bool includeSpecificPlayer = false,
      String? specificPlayerId,
      String? specificPlayerName, // Tên này giờ đã được đảm bảo là không rỗng
      int? specificPlayerScore,
    }) {
      List<LeaderBoardModel> data = [];
      final random = Random();

      for (int i = 0; i < count; i++) {
        int score = baseScore -
            (i * scoreDecrement) +
            random.nextInt(scoreDecrement ~/ 2);
        if (score < 0) score = 0;

        data.add(LeaderBoardModel(
          // Sử dụng UUID cho ID document của người chơi mock để đảm bảo duy nhất
          id: '${prefix}_mock_${_uuid.v4().substring(0, 8)}',
          name: '$prefix Player ${i + 1}', // Tên này luôn không rỗng
          highScore: score,
          correctAnswers: random.nextInt(score ~/ 5 + 1),
          totalQuestions: random.nextInt(score ~/ 3 + 1),
          lastUpdated:
              DateTime.now().millisecondsSinceEpoch - random.nextInt(10000000),
          periodStartTimestamp: periodStartTimestamp,
        ));
      }

      // Xử lý người chơi hiện tại
      if (includeSpecificPlayer &&
          specificPlayerId != null &&
          specificPlayerName != null &&
          specificPlayerScore != null) {
        // Tìm xem người chơi hiện tại đã có trong danh sách mock ngẫu nhiên chưa
        int existingIndex =
            data.indexWhere((element) => element.id == specificPlayerId);
        if (existingIndex != -1) {
          // Nếu đã có (trùng ID), cập nhật thông tin
          data[existingIndex] = data[existingIndex].copyWith(
            name: specificPlayerName,
            highScore: specificPlayerScore,
            lastUpdated: DateTime.now().millisecondsSinceEpoch,
            periodStartTimestamp: periodStartTimestamp,
          );
        } else {
          // Nếu chưa có, thêm người chơi hiện tại vào danh sách
          data.add(LeaderBoardModel(
            id: specificPlayerId, // ID của người chơi hiện tại
            name: specificPlayerName, // Tên của người chơi hiện tại
            highScore: specificPlayerScore,
            correctAnswers: random.nextInt(specificPlayerScore ~/ 5 + 1),
            totalQuestions: random.nextInt(specificPlayerScore ~/ 3 + 1),
            lastUpdated: DateTime.now().millisecondsSinceEpoch,
            periodStartTimestamp: periodStartTimestamp,
          ));
        }
      }

      // Sắp xếp và gán rank (chỉ dùng cục bộ)
      data.sort((a, b) => b.highScore.compareTo(a.highScore));
      for (int i = 0; i < data.length; i++) {
        data[i].rank = i + 1;
      }
      return data;
    }

    // Bước 2: Tạo dữ liệu mock cho từng leaderboard bằng hàm nội bộ _generateLocalMockData
    final List<LeaderBoardModel> mockOverall = _generateLocalMockData(
      count: numberOfOverallPlayers,
      prefix: 'Overall',
      baseScore: 10000,
      scoreDecrement: 200,
      includeSpecificPlayer: true,
      specificPlayerId: currentDeviceId,
      specificPlayerName:
          currentUserName, // Dùng currentUserName đã được đảm bảo
      specificPlayerScore: currentUserScore + Random().nextInt(500),
    );

    final now = DateTime.now();
    final todayStart = getStartOfDayTimestamp(now);
    final weekStart = getStartOfWeekTimestamp(now);
    final monthStart = getStartOfMonthTimestamp(now);

    final List<LeaderBoardModel> mockDaily = _generateLocalMockData(
      count: numberOfDailyPlayers,
      prefix: 'Daily',
      periodStartTimestamp: todayStart,
      baseScore: 3000,
      scoreDecrement: 100,
      includeSpecificPlayer: true,
      specificPlayerId: currentDeviceId,
      specificPlayerName:
          currentUserName, // Dùng currentUserName đã được đảm bảo
      specificPlayerScore: currentUserScore,
    );

    final List<LeaderBoardModel> mockWeekly = _generateLocalMockData(
      count: numberOfWeeklyPlayers,
      prefix: 'Weekly',
      periodStartTimestamp: weekStart,
      baseScore: 6000,
      scoreDecrement: 150,
      includeSpecificPlayer: true,
      specificPlayerId: currentDeviceId,
      specificPlayerName:
          currentUserName, // Dùng currentUserName đã được đảm bảo
      specificPlayerScore: currentUserScore + Random().nextInt(100),
    );

    final List<LeaderBoardModel> mockMonthly = _generateLocalMockData(
      count: numberOfMonthlyPlayers,
      prefix: 'Monthly',
      periodStartTimestamp: monthStart,
      baseScore: 8000,
      scoreDecrement: 180,
      includeSpecificPlayer: true,
      specificPlayerId: currentDeviceId,
      specificPlayerName:
          currentUserName, // Dùng currentUserName đã được đảm bảo
      specificPlayerScore: currentUserScore + Random().nextInt(200),
    );

    // Bước 3: Đẩy dữ liệu lên Firestore
    await _uploadMockDataToCollection(_overallCollection, mockOverall);
    await _uploadMockDataToCollection(_dailyCollection, mockDaily);
    await _uploadMockDataToCollection(_weeklyCollection, mockWeekly);
    await _uploadMockDataToCollection(_monthlyCollection, mockMonthly);

    // Bước 4: Đăng ký tên người dùng trong collection 'usernames'
    final allMockPlayers =
        [...mockOverall, ...mockDaily, ...mockWeekly, ...mockMonthly]
            .fold<Map<String, LeaderBoardModel>>({}, (map, player) {
              map[player.id] = player;
              return map;
            })
            .values
            .toList();

    final batch = _firestore.batch();
    for (var player in allMockPlayers) {
      final usernameLowercase = player.name.toLowerCase();

      // Đảm bảo usernameLowercase không rỗng trước khi dùng làm document ID
      if (usernameLowercase.trim().isEmpty) {
        print(
            '  Cảnh báo: Tên người chơi rỗng cho ID ${player.id} khi đăng ký vào usernames. Bỏ qua.');
        continue;
      }

      final usernameDocRef =
          _firestore.collection(_usernamesCollection).doc(usernameLowercase);
      batch.set(usernameDocRef, {
        'isUsed': true,
        'userId': player.id,
        'timestamp': FieldValue.serverTimestamp(),
      });
    }
    await batch.commit();
    print("Đã đăng ký ${allMockPlayers.length} tên người dùng mock.");

    print("--- Hoàn tất tạo và đẩy dữ liệu mock lên Firestore ---");
  }

  // Hàm helper để đẩy danh sách LeaderBoardModel lên một collection cụ thể
  Future<void> _uploadMockDataToCollection(
      String collectionName, List<LeaderBoardModel> data) async {
    print(
        "  Đang đẩy ${data.length} document vào collection '$collectionName'...");
    final batch = _firestore.batch();
    for (var model in data) {
      final docRef = _firestore.collection(collectionName).doc(model.id);
      Map<String, dynamic> dataToUpload = model.toMap();
      // Đảm bảo deviceId có mặt trong dữ liệu nếu chưa có
      if (!dataToUpload.containsKey('deviceId')) {
        dataToUpload['deviceId'] = model.id; // Dùng id của model làm deviceId
      }
      batch.set(docRef, dataToUpload);
    }
    await batch.commit();
    print("  ✅ Đã đẩy ${data.length} document vào '$collectionName'.");
  }
}
