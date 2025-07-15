import 'package:shared_preferences/shared_preferences.dart';

class SettingsStore {
  static SettingsStore? _instance;
  static SettingsStore instance = _instance ??= SettingsStore._internal();

  SettingsStore._internal();

  late SharedPreferences prefs;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    prefs = await SharedPreferences.getInstance();
    _initialized = true;
  }

  // Sound settings
  bool get sound => prefs.getBool('sound') ?? true;
  Future<void> setSound(bool value) async {
    await init();
    await prefs.setBool('sound', value);
  }

  // Vibration settings
  bool get vibration => prefs.getBool('vibration') ?? true;
  Future<void> setVibration(bool value) async {
    await init();
    await prefs.setBool('vibration', value);
  }

  // Effect settings
  bool get effect => prefs.getBool('effect') ?? true;
  Future<void> setEffect(bool value) async {
    await init();
    await prefs.setBool('effect', value);
  }

  // General methods
  Future<void> setKey(String key, String value) async {
    await init();
    await prefs.setString(key, value);
  }

  Future<String?> getKey(String key) async {
    await init();
    return prefs.getString(key);
  }
}
