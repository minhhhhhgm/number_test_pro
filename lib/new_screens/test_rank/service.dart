// lib/services/leaderboard_service.dart
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:numbers/models/rank_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class Service {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Uuid _uuid = const Uuid();

  static const String _leaderboardCollection = 'leaderboard';
  static const String _usernamesCollection =
      'usernames'; // Để kiểm tra tên duy nhất

  Service();

  Future<String> getDeviceId() async {
    final _prefs = await SharedPreferences.getInstance();

    String? deviceId = _prefs.getString('deviceId');
    if (deviceId == null) {
      if (deviceId == null || deviceId.isEmpty) {
        deviceId = _uuid.v4();
      }
      await _prefs.setString('deviceId', deviceId);
    }
    return deviceId;
  }

  Future<String?> getPlayerName() async {
    final _prefs = await SharedPreferences.getInstance();

    return _prefs.getString('playerName');
  }

  Future<void> setPlayerName(
      {required String newName, required int score}) async {
    final _prefs = await SharedPreferences.getInstance();

    final deviceId = await getDeviceId();
    final oldName = await getPlayerName();
    final String lowercaseNewName = newName.toLowerCase();

    if (newName.trim().isEmpty) {
      throw Exception('Tên người dùng không được để trống.');
    }

    try {
      await _firestore.runTransaction((transaction) async {
        final newUsernameDocRef =
            _firestore.collection(_usernamesCollection).doc(lowercaseNewName);
        final newUsernameSnapshot = await transaction.get(newUsernameDocRef);

        DocumentSnapshot<Map<String, dynamic>>? oldUsernameSnapshot;
        if (oldName != null && oldName.isNotEmpty) {
          final String lowercaseOldName = oldName.toLowerCase();
          final oldUsernameDocRef =
              _firestore.collection(_usernamesCollection).doc(lowercaseOldName);
          oldUsernameSnapshot = await transaction.get(oldUsernameDocRef)
              as DocumentSnapshot<Map<String, dynamic>>?;
        }

        final userDocRef =
            _firestore.collection(_leaderboardCollection).doc(deviceId);

        if (newUsernameSnapshot.exists) {
          final existingUserId =
              newUsernameSnapshot.data()?['userId'] as String?;
          if (existingUserId == deviceId) {
            print(
                '  ℹ️ Tên "$newName" đã là của người dùng hiện tại ($deviceId).');
            return;
          } else {
            print(
                '  ❌ Tên "$newName" đã được người khác sử dụng ($existingUserId).');
            throw Exception('Tên người dùng đã tồn tại.');
          }
        }

        if (oldUsernameSnapshot != null &&
            oldUsernameSnapshot.exists &&
            oldUsernameSnapshot.data()?['userId'] == deviceId) {
          transaction.delete(oldUsernameSnapshot.reference);
          print('  ✅ Đã xóa đăng ký tên cũ: "$oldName"');
        }

        transaction.set(newUsernameDocRef, {
          'isUsed': true,
          'userId': deviceId,
        });
        print('  ✅ Đã đăng ký tên mới trong _usernamesCollection: "$newName"');

        transaction.set(
            userDocRef,
            {
              'name': newName,
              'highScore': score,
              'deviceId': deviceId,
            },
            SetOptions(merge: true));
      });

      await _prefs.setString('playerName', newName);
      print('  ✅ Đã lưu tên mới cục bộ: "$newName"');
    } catch (e) {
      print('  ❌ Lỗi khi thiết lập tên người chơi: $e');
      rethrow;
    }
  }

  Future<void> updateHighScore({required int score}) async {
    final deviceId = await getDeviceId();
    final playerName = await getPlayerName();

    if (playerName == null || playerName.isEmpty) {
      print("❗ Lỗi: Người chơi chưa có tên. Không thể cập nhật điểm.");
      return;
      // throw Exception("Vui lòng đặt tên trước khi cập nhật điểm!");
    }

    print('\n--- Cập nhật điểm: $score cho "$playerName" ---');

    await _firestore.runTransaction((transaction) async {
      final userDocRef =
          _firestore.collection(_leaderboardCollection).doc(deviceId);
      final snapshot = await transaction.get(userDocRef);

      final currentHighScore = snapshot.data()?['highScore'] as int? ?? 0;

      if (score > currentHighScore) {
        transaction.set(
            userDocRef,
            {
              'name': playerName,
              'highScore': score,
              'deviceId': deviceId,
            },
            SetOptions(merge: true));
        print(
            '  ✅ Đã cập nhật điểm cao nhất: $score (trước đó: $currentHighScore).');
      } else {
        print(
            '  ℹ️ Điểm mới ($score) không cao hơn điểm hiện tại ($currentHighScore). Không cập nhật.');
      }
    }).catchError((e) {
      print("  ❌ Lỗi khi cập nhật điểm cao nhất: $e");
    });
  }

  Future<List<RankModel>> getTop10Leaderboard() async {
    print('\n--- Đang lấy Top 10 Leaderboard ---');
    try {
      final querySnapshot = await _firestore
          .collection(_leaderboardCollection)
          .orderBy('highScore', descending: true)
          .limit(50)
          .get();

      final List<RankModel> leaderboard = [];
      int rank = 1;
      for (var doc in querySnapshot.docs) {
        final player = RankModel.fromMap(doc.data(), doc.id);
        leaderboard.add(player.copyWith(rank: rank)); // Gán rank
        rank++;
      }
      print('  ✅ Đã lấy ${leaderboard.length} người chơi từ leaderboard.');
      return leaderboard;
    } catch (e) {
      print('  ❌ Lỗi khi lấy leaderboard: $e');
      rethrow;
    }
  }

  // Hàm thêm người chơi mock từng người một
  Future<void> addMockPlayer({
    String? name,
    int? score,
    bool isCurrentPlayer = false,
  }) async {
    print('\n--- Thêm người chơi Mock ---');
    final random = Random();
    String newId;
    String newName;
    int newScore;

    if (isCurrentPlayer) {
      newId = await getDeviceId();
      newName =
          name ?? (await getPlayerName() ?? "Player_${random.nextInt(100000)}");
      newScore = score ?? (random.nextInt(10000) + 1);
      // Đảm bảo tên được set nếu là người chơi hiện tại và chưa có tên
      if (await getPlayerName() == null) {
        await setPlayerName(newName: newName, score: newScore);
      }
      print(
          '  Tạo dữ liệu cho người chơi hiện tại: "$newName" - $newScore điểm');
    } else {
      newId = _uuid.v4();
      newName = name ?? "Guest_${_uuid.v4().substring(0, 4)}";
      newScore = score ?? (random.nextInt(10000) + 1);
      print('  Tạo dữ liệu cho người chơi khách: "$newName" - $newScore điểm');
    }

    final userDocRef = _firestore.collection(_leaderboardCollection).doc(newId);

    try {
      await userDocRef.set({
        'name': newName,
        'highScore': newScore,
        'deviceId': newId,
      }, SetOptions(merge: true));
      print(
          '  ✅ Đã thêm/cập nhật người chơi mock "$newName" với điểm $newScore.');
    } catch (e) {
      print('  ❌ Lỗi khi thêm người chơi mock: $e');
      rethrow;
    }
  }

  Future<void> cleanUpTestData() async {
    final _prefs = await SharedPreferences.getInstance();

    print('\n--- Đang xóa toàn bộ dữ liệu test ---');
    try {
      final leaderboardDocs =
          await _firestore.collection(_leaderboardCollection).get();
      for (var doc in leaderboardDocs.docs) {
        await doc.reference.delete();
      }
      print('  ✅ Đã xóa collection leaderboard.');

      final usernamesDocs =
          await _firestore.collection(_usernamesCollection).get();
      for (var doc in usernamesDocs.docs) {
        await doc.reference.delete();
      }
      print('  ✅ Đã xóa collection usernames.');

      await _prefs.remove('deviceId');
      await _prefs.remove('playerName');
      print('  ✅ Đã xóa dữ liệu local (deviceId, playerName).');

      print('--- Xóa dữ liệu test hoàn tất ---');
    } catch (e) {
      print('  ❌ Lỗi khi xóa dữ liệu test: $e');
      rethrow;
    }
  }
}
