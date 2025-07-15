import 'package:shared_preferences/shared_preferences.dart';

class ScoreService {
  static const String _keyScore = 'temp_score';
  static const String _keyTotal = 'temp_total';
  static const String _keySuccess = 'temp_success';
  static const String _keyFail = 'temp_fail';
  static const String _keyTotalStore = 'total_store';

  /// Gọi hàm này khi kết thúc 1 màn chơi
  Future<void> saveGameResult({
    required int total,
    required int success,
    required int fail,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final score = _calculateScore(success: success, fail: fail, total: total);

    await prefs.setInt(_keyScore, score);
    await prefs.setInt(_keyTotal, total);
    await prefs.setInt(_keySuccess, success);
    await prefs.setInt(_keyFail, fail);
  }

  Future<void> saveScore({
    required int total,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    final int previousTotal = prefs.getInt(_keyTotalStore) ?? 0;
    final int newTotal = previousTotal + total;

    await prefs.setInt(_keyTotalStore, newTotal);
  }

  Future<int?> getScore() async {
    final prefs = await SharedPreferences.getInstance();

    return await prefs.getInt(_keyTotalStore);
  }

  /// Tính điểm dựa trên logic riêng
  int _calculateScore({
    required int total,
    required int success,
    required int fail,
  }) {
    int basePoint = 10;
    int successPoint = success * basePoint;
    int penalty = fail * 5;

    return successPoint - penalty;
  }

  /// Lấy dữ liệu đã lưu tạm để đẩy lên Firestore hoặc hiển thị
  Future<Map<String, dynamic>> getCalculatedScore() async {
    final prefs = await SharedPreferences.getInstance();

    return {
      'score': prefs.getInt(_keyScore) ?? 0,
      'total': prefs.getInt(_keyTotal) ?? 0,
      'success': prefs.getInt(_keySuccess) ?? 0,
      'fail': prefs.getInt(_keyFail) ?? 0,
    };
  }

  /// Xoá dữ liệu sau khi đã submit lên Firestore
  Future<void> clearTempData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyScore);
    await prefs.remove(_keyTotal);
    await prefs.remove(_keySuccess);
    await prefs.remove(_keyFail);
  }
}
