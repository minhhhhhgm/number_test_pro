import 'package:shared_preferences/shared_preferences.dart';

class MainStoreService {
  Future<void> setKey({
    required String key,
    required String data,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(key, data);
  }

  Future<String?> getKey({required String key}) async {
    final prefs = await SharedPreferences.getInstance();

    return await prefs.getString(key);
  }
}
