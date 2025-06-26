import 'package:shared_preferences/shared_preferences.dart';

class SettingsStore {
  late SharedPreferences prefs;

  init() async {
    prefs = await SharedPreferences.getInstance();
  }

  setKey(String key, String value) async {
    await init();
    return prefs.setString(key, value);
  }

  Future<String?> getKey(String key) async {
    await init();
    return prefs.getString(key);
  }
}
