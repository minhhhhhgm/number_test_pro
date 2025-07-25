import 'dart:developer';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:numbers/di/service_locator.dart';
import 'package:numbers/service/sound_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsUIDemoScreen extends StatefulWidget {
  const SettingsUIDemoScreen({super.key});

  @override
  State<SettingsUIDemoScreen> createState() => _SettingsUIDemoScreenState();
}

class _SettingsUIDemoScreenState extends State<SettingsUIDemoScreen>
    with AutomaticKeepAliveClientMixin {
  bool _isSoundOn = true;
  String _currentLanguage = 'vi';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _isSoundOn = prefs.getBool('isSoundEnable') ?? true;
        _currentLanguage = context.locale.languageCode;
        _isLoading = false;
      });
    } catch (e) {
      log('Error loading settings: $e');
    }
  }

  void _onSoundToggle(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isSoundEnable', value);
    getIt<MainSoundService>().updateConfigSounds(value);
    setState(() {
      _isSoundOn = value;
    });
  }

  void _onLanguageChange(String value, BuildContext context) async {
    // final prefs = await SharedPreferences.getInstance();
    // await prefs.setString('languageCode', value);
    final newLocale = Locale(value);
    await context.setLocale(newLocale);
    setState(() {
      _currentLanguage = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF0E0B8).withOpacity(0.7),
      appBar: AppBar(
        title: Text(
          'setting'.tr(),
          style:
              TextStyle(color: Color(0xFF5D5D5D), fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFF0E0B8).withOpacity(0.2),
        foregroundColor: const Color(0xFF5D5D5D),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Switch Âm thanh
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              elevation: 5,
              color: Colors.white,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _isSoundOn ? Icons.volume_up : Icons.volume_off,
                          color: const Color(0xFF5D5D5D),
                        ),
                        const SizedBox(width: 15),
                        Text(
                          'sound'.tr(),
                          style: TextStyle(
                            fontSize: 18,
                            color: Color(0xFF5D5D5D),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    Switch(
                      value: _isSoundOn,
                      onChanged: _onSoundToggle,
                      activeColor: const Color(0xFFEDAC4D),
                      inactiveThumbColor: Colors.grey,
                      inactiveTrackColor: Colors.grey.shade300,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Dropdown Ngôn ngữ
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              elevation: 5,
              color: Colors.white,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.language, color: Color(0xFF5D5D5D)),
                        SizedBox(width: 15),
                        Text(
                          'language'.tr(),
                          style: TextStyle(
                            fontSize: 18,
                            color: Color(0xFF5D5D5D),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _currentLanguage,
                        icon: const Icon(Icons.arrow_drop_down,
                            color: Color(0xFF5D5D5D)),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            _onLanguageChange(newValue, context);
                          }
                        },
                        items: const <String>['vi', 'en']
                            .map<DropdownMenuItem<String>>((String value) {
                          String displayText = value == 'vi'
                              ? 'vietnamese'.tr()
                              : 'english'.tr();
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(
                              displayText,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Color(0xFF5D5D5D),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
