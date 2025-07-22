import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:numbers/di/service_locator.dart'; // Đảm bảo đường dẫn này đúng
import 'package:numbers/service/main_store_service.dart'; // Đảm bảo đường dẫn này đúng
import 'package:uuid/uuid.dart';

// Đây là interface (giao diện) của dịch vụ.
// Giúp bạn dễ dàng mock (giả lập) trong các bài kiểm thử.
abstract class ILeaderBoardService {
  Future<String> getDeviceId();
  Future<String?> getPlayerName();
  Future<bool> setPlayerName({required String newName});
  Future<void> updateHighScore({required int score});
  Future<List<LeaderBoardModel>> getTop10Leaderboard();
  Future<void> cleanUpTestData(); // Đổi tên để rõ ràng hơn
  Future<void> uploadMockTestData(
      {int numberOfPlayers = 20}); // Đổi tên để rõ ràng hơn
}

class LeaderBoardServiceTest implements ILeaderBoardService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Uuid _uuid = Uuid();
  final _mainStoreService =
      getIt<MainStoreService>(); // Đổi tên biến cho rõ ràng hơn

  // Tên collection chính (chỉ dùng 1 collection cho đơn giản)
  final String _leaderboardCollection = 'leaderboard_players';
  final String _usernamesCollection =
      'usernames'; // Dùng để quản lý tên duy nhất

  // Lấy hoặc tạo Device ID duy nhất cho người dùng
  @override
  Future<String> getDeviceId() async {
    String? deviceId = await _mainStoreService.getKey(key: 'deviceId');
    if (deviceId == null || deviceId.isEmpty) {
      deviceId = _uuid.v4();
      await _mainStoreService.setKey(key: 'deviceId', data: deviceId);
    }
    return deviceId;
  }

  // Lấy tên người chơi từ local storage
  @override
  Future<String?> getPlayerName() async {
    return await _mainStoreService.getKey(key: 'name');
  }

  // Thiết lập tên người chơi mới
  // - Kiểm tra tính duy nhất của tên
  // - Cập nhật tên trong Firestore và local storage
  @override
  Future<bool> setPlayerName({required String newName}) async {
    final deviceId = await getDeviceId();
    final oldName = await _mainStoreService.getKey(key: 'name');
    final String lowercaseNewName = newName.toLowerCase();

    print(
        '\n--- Đang cố gắng thiết lập tên: "$newName" (DeviceId: $deviceId) ---');

    if (newName.trim().isEmpty) {
      print('  ❌ Tên không được để trống.');
      throw Exception('Tên người dùng không được để trống.');
    }

    try {
      await _firestore.runTransaction((transaction) async {
        // --- BẮT ĐẦU CÁC THAO TÁC ĐỌC ---

        // Đọc 1: Kiểm tra tài liệu tên mới
        final newUsernameDocRef =
            _firestore.collection(_usernamesCollection).doc(lowercaseNewName);
        final newUsernameSnapshot = await transaction.get(newUsernameDocRef);

        // Đọc 2: Đọc tài liệu tên cũ (nếu có tên cũ)
        DocumentSnapshot<Map<String, dynamic>>? oldUsernameSnapshot;
        if (oldName != null && oldName.isNotEmpty) {
          final String lowercaseOldName = oldName.toLowerCase();
          final oldUsernameDocRef =
              _firestore.collection(_usernamesCollection).doc(lowercaseOldName);
          oldUsernameSnapshot = await transaction.get(oldUsernameDocRef)
              as DocumentSnapshot<Map<String, dynamic>>?;
        }

        // Đọc 3: Đọc tài liệu người dùng chính (để lấy highScore)
        final userDocRef =
            _firestore.collection(_leaderboardCollection).doc(deviceId);
        final userDocSnapshot =
            await transaction.get(userDocRef); // ĐỌC highscore ở đây

        // Lấy highscore sau khi đã đọc
        final int existingHighScore =
            userDocSnapshot.data()?['highScore'] as int? ?? 0;

        // --- KẾT THÚC CÁC THAO TÁC ĐỌC ---

        // --- BẮT ĐẦU CÁC THAO TÁC GHI ---

        // Logic kiểm tra tên mới
        if (newUsernameSnapshot.exists) {
          final existingUserId =
              newUsernameSnapshot.data()?['userId'] as String?;
          if (existingUserId == deviceId) {
            print(
                '  ℹ️ Tên "$newName" đã là của người dùng hiện tại ($deviceId).');
            return; // Thoát khỏi transaction nếu tên đã là của mình
          } else {
            print(
                '  ❌ Tên "$newName" đã được người khác sử dụng ($existingUserId).');
            throw Exception(
                'Tên người dùng đã tồn tại. Vui lòng chọn tên khác.');
          }
        }

        // Xóa đăng ký tên cũ (nếu hợp lệ)
        if (oldUsernameSnapshot != null &&
            oldUsernameSnapshot.exists &&
            oldUsernameSnapshot.data()?['userId'] == deviceId) {
          transaction.delete(oldUsernameSnapshot.reference);
          print('  ✅ Đã xóa đăng ký tên cũ: "$oldName"');
        }

        // Đăng ký tên mới
        transaction.set(newUsernameDocRef, {
          'isUsed': true,
          'userId': deviceId,
          'timestamp': FieldValue.serverTimestamp(),
        });
        print('  ✅ Đã đăng ký tên mới trong _usernamesCollection: "$newName"');

        // Cập nhật tên và điểm trong tài liệu người dùng chính
        transaction.set(
            userDocRef,
            {
              'name': newName,
              'lastUpdated': FieldValue.serverTimestamp(),
              'highScore': existingHighScore, // Sử dụng giá trị đã đọc
            },
            SetOptions(merge: true));
        print(
            '  ✅ Đã cập nhật tên trong tài liệu người dùng chính: "$newName"');
      });

      // Nếu transaction thành công, lưu tên vào local store
      await _mainStoreService.setKey(key: 'name', data: newName);
      print('  ✅ Đã lưu tên mới cục bộ: "$newName"');
      return true;
    } catch (e) {
      print('  ❌ Lỗi khi thiết lập tên người chơi: $e');
      rethrow;
    }
  }

  // Cập nhật điểm số cao nhất của người chơi
  // Chỉ cần cập nhật điểm số. Tên đã được đặt qua setPlayerName.
  @override
  Future<void> updateHighScore({required int score}) async {
    final deviceId = await getDeviceId();
    final playerName = await getPlayerName(); // Lấy tên từ local

    if (playerName == null || playerName.isEmpty) {
      print("❗ Lỗi: Người chơi chưa có tên. Không thể cập nhật điểm.");
      throw Exception("Vui lòng đặt tên trước khi cập nhật điểm!");
    }

    print('\n--- Cập nhật điểm: $score cho "$playerName" ---');

    // Firestore transaction để đảm bảo tính nhất quán
    await _firestore.runTransaction((transaction) async {
      final userDocRef =
          _firestore.collection(_leaderboardCollection).doc(deviceId);
      final snapshot = await transaction.get(userDocRef);

      final currentHighScore = snapshot.data()?['highScore'] as int? ?? 0;

      // Chỉ cập nhật nếu điểm mới cao hơn điểm hiện tại
      if (score > currentHighScore) {
        transaction.set(
            userDocRef,
            {
              'name': playerName, // Cập nhật tên (dù đã có, để đảm bảo sync)
              'highScore': score,
              'lastUpdated': FieldValue.serverTimestamp(),
              'deviceId': deviceId, // Đảm bảo deviceId có mặt
            },
            SetOptions(merge: true)); // Merge để chỉ cập nhật các trường này
        print(
            '  ✅ Đã cập nhật điểm cao nhất: $score (trước đó: $currentHighScore).');
      } else {
        print(
            '  ℹ️ Điểm mới ($score) không cao hơn điểm hiện tại ($currentHighScore). Không cập nhật.');
      }
    }).catchError((e) {
      print("  ❌ Lỗi khi cập nhật điểm cao nhất: $e");
      // rethrow;
    });
  }

  // Lấy Top 10 người chơi điểm cao nhất
  @override
  Future<List<LeaderBoardModel>> getTop10Leaderboard({int limit = 10}) async {
    try {
      final QuerySnapshot querySnapshot = await _firestore
          .collection(_leaderboardCollection)
          .orderBy('highScore', descending: true)
          .limit(limit)
          .get();

      List<LeaderBoardModel> resultList = [];
      int rank = 1;
      for (var doc in querySnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        resultList.add(LeaderBoardModel.fromMap(data, doc.id)..rank = rank++);
      }

      final currentDeviceId = await getDeviceId();
      final currentUserName = await getPlayerName();

      // Chỉ xử lý người chơi hiện tại nếu họ có tên (đã đặt tên)
      if (currentUserName != null && currentUserName.isNotEmpty) {
        bool isInTopN = resultList.any((e) => e.id == currentDeviceId);

        // Nếu người chơi hiện tại KHÔNG nằm trong Top N được trả về
        if (!isInTopN) {
          final currentUserDoc = await _firestore
              .collection(_leaderboardCollection)
              .doc(currentDeviceId)
              .get();

          if (currentUserDoc.exists) {
            // Người chơi hiện tại có điểm nhưng không trong Top N
            final userData = currentUserDoc.data() as Map<String, dynamic>;
            final userHighScore = userData['highScore'] as int? ?? 0;

            // Đếm số lượng người có điểm cao hơn để xác định rank chính xác
            final higherScoreSnapshot = await _firestore
                .collection(_leaderboardCollection)
                .where('highScore', isGreaterThan: userHighScore)
                .count()
                .get();
            final currentUserRank = (higherScoreSnapshot.count ?? 0) + 1;

            resultList.add(LeaderBoardModel.fromMap(userData, currentDeviceId)
              ..rank = currentUserRank);
          } else {
            // Người chơi hiện tại chưa có tài liệu (chưa có điểm)
            resultList.add(LeaderBoardModel(
              id: currentDeviceId,
              name: currentUserName,
              highScore: 0,
              lastUpdated: DateTime.now().millisecondsSinceEpoch,
              rank: -1, // "No Rank"
            ));
          }
        }
      }

      return resultList;
    } catch (e) {
      print("❌ Lỗi khi lấy leaderboard: $e");
      return [];
    }
  }

  // Hàm để xóa toàn bộ dữ liệu test (đặc biệt hữu ích khi phát triển)
  @override
  Future<void> cleanUpTestData() async {
    print("\n--- Đang xóa dữ liệu test ---");
    final collections = [_leaderboardCollection, _usernamesCollection];

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
    // Xóa deviceId và name trong MainStoreService để giả lập người chơi mới
    await _mainStoreService.setKey(key: 'deviceId', data: '');
    await _mainStoreService.setKey(key: 'name', data: '');
    print("--- Hoàn tất xóa dữ liệu test và cài đặt người chơi mới ---");
  }

  // Hàm để upload dữ liệu mock (tên và điểm) lên Firebase
  // CHỈ DÙNG CHO MÔI TRƯỜNG PHÁT TRIỂN/KIỂM THỬ!
  @override
  Future<void> uploadMockTestData({int numberOfPlayers = 20}) async {
    print("\n--- Bắt đầu tạo và đẩy dữ liệu mock lên Firestore ---");

    final String currentDeviceId = await getDeviceId();
    String? currentUserName = await getPlayerName();

    // Bước quan trọng: Đảm bảo người chơi hiện tại có tên hợp lệ
    if (currentUserName == null || currentUserName.trim().isEmpty) {
      final String defaultMockName = 'Player_${_uuid.v4().substring(0, 6)}';
      print(
          '  Người chơi hiện tại chưa có tên. Đang thiết lập tên mặc định: "$defaultMockName"');
      try {
        await setPlayerName(
            newName: defaultMockName); // Gọi setPlayerName để lưu
        currentUserName = defaultMockName;
      } catch (e) {
        print("  ❌ Lỗi khi thiết lập tên mặc định: $e. Dừng tạo mock data.");
        return;
      }
    }

    await cleanUpTestData(); // Dọn dẹp dữ liệu cũ trước khi tạo mới
    print("Đã dọn dẹp dữ liệu cũ.");

    final List<LeaderBoardModel> mockPlayers = [];
    final random = Random();
    final batch = _firestore.batch();
    final DateTime now = DateTime.now();

    // Tạo dữ liệu cho người chơi hiện tại
    final int currentUserScore =
        5000 + random.nextInt(2000); // Điểm cao để dễ vào top
    final currentUserData = LeaderBoardModel(
      id: currentDeviceId,
      name: currentUserName, // Đảm bảo không null
      highScore: currentUserScore,
      correctAnswers: 0,
      totalQuestions: 0,
      lastUpdated: now.millisecondsSinceEpoch,
      rank: 0, // Rank sẽ được tính sau
    );
    mockPlayers.add(currentUserData);
    print(
        '  Đã tạo dữ liệu mock cho người chơi hiện tại: ${currentUserData.name} - ${currentUserData.highScore} điểm');

    // Tạo dữ liệu cho các người chơi mock khác
    for (int i = 0; i < numberOfPlayers - 1; i++) {
      // Trừ đi 1 vì đã thêm người chơi hiện tại
      final mockId = 'mock_user_${_uuid.v4().substring(0, 8)}';
      final mockName = 'Guest_${_uuid.v4().substring(0, 4)}';
      final mockScore = random.nextInt(6000); // Điểm ngẫu nhiên

      mockPlayers.add(LeaderBoardModel(
        id: mockId,
        name: mockName,
        highScore: mockScore,
        correctAnswers: 0,
        totalQuestions: 0,
        lastUpdated: now.millisecondsSinceEpoch,
        rank: 0,
      ));
    }

    // Đẩy tất cả dữ liệu mock (bao gồm người chơi hiện tại) lên Firestore
    for (var player in mockPlayers) {
      final docRef =
          _firestore.collection(_leaderboardCollection).doc(player.id);
      batch.set(docRef, player.toMap()); // Sử dụng toMap() từ LeaderBoardModel

      // Đăng ký tên người dùng vào collection 'usernames'
      final usernameLowercase = player.name.toLowerCase();
      final usernameDocRef =
          _firestore.collection(_usernamesCollection).doc(usernameLowercase);
      batch.set(usernameDocRef, {
        'isUsed': true,
        'userId': player.id,
        'timestamp': FieldValue.serverTimestamp(),
      });
    }

    await batch.commit();
    print(
        "  ✅ Hoàn tất đẩy ${mockPlayers.length} người chơi mock lên Firestore.");
    print("--- Hoàn tất tạo và đẩy dữ liệu mock lên Firestore ---");
  }
}

// lib/models/leader_board_model.dart
class LeaderBoardModel {
  String id; // deviceId
  String name;
  int highScore;
  int correctAnswers; // Có thể bỏ nếu chỉ muốn tên và điểm
  int totalQuestions; // Có thể bỏ
  int lastUpdated; // Thời gian cập nhật cuối cùng
  int rank; // Rank được gán sau khi lấy về

  LeaderBoardModel({
    required this.id,
    required this.name,
    required this.highScore,
    this.correctAnswers = 0,
    this.totalQuestions = 0,
    required this.lastUpdated,
    this.rank = 0,
  });

  factory LeaderBoardModel.fromMap(
      Map<String, dynamic> map, String documentId) {
    return LeaderBoardModel(
      id: documentId, // ID của document chính là deviceId
      name: map['name'] as String? ?? 'N/A',
      highScore: map['highScore'] as int? ?? 0,
      correctAnswers: map['correctAnswers'] as int? ?? 0,
      totalQuestions: map['totalQuestions'] as int? ?? 0,
      lastUpdated: map['lastUpdated'] as int? ?? 0,
      rank: 0, // Rank sẽ được gán sau
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'highScore': highScore,
      'correctAnswers': correctAnswers,
      'totalQuestions': totalQuestions,
      'lastUpdated': lastUpdated,
      // 'deviceId': id, // document ID đã là deviceId, không cần field riêng
    };
  }

  // Nếu bạn cần copyWith cho việc cập nhật model
  LeaderBoardModel copyWith({
    String? id,
    String? name,
    int? highScore,
    int? correctAnswers,
    int? totalQuestions,
    int? lastUpdated,
    int? rank,
  }) {
    return LeaderBoardModel(
      id: id ?? this.id,
      name: name ?? this.name,
      highScore: highScore ?? this.highScore,
      correctAnswers: correctAnswers ?? this.correctAnswers,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      rank: rank ?? this.rank,
    );
  }
}
