import 'package:shared_preferences/shared_preferences.dart';

class ScoreService {
  static const String _keyTotalStore = 'total_store';
  static const String _keyPoint = 'total_Point';

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

  Future<void> savePoint({
    required int total,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    final int previousTotal = prefs.getInt(_keyPoint) ?? 0;
    final int newTotal = previousTotal + total;

    await prefs.setInt(_keyTotalStore, newTotal);
  }

  Future<void> usePoint({
    required int total,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    final int previousTotal = prefs.getInt(_keyPoint) ?? 0;
    if (previousTotal <= 0) {
      return;
    }
    final int newTotal = previousTotal - total;

    await prefs.setInt(_keyTotalStore, newTotal);
  }

  Future<int?> getPoint() async {
    final prefs = await SharedPreferences.getInstance();

    return await prefs.getInt(_keyPoint);
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
}
