import 'dart:async';
import 'dart:ui';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleService {
  // Stream controller cho locale changes
  final StreamController<Locale> _localeStreamController =
      StreamController<Locale>.broadcast();

  Stream<Locale> get onLocaleChanged => _localeStreamController.stream;

  Future<Locale> getStartupLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final isFirstRun = await prefs.getBool('first_run');

    if (isFirstRun == null) {
      await prefs.setString('locale', 'vi');
      return Locale('vi');
    } else {
      final savedLocale = await await prefs.getString('locale');

      return Locale(savedLocale!);
    }
  }

  // Thay đổi locale và lưu vào storage
  Future<bool> changeLocale(BuildContext context, Locale locale) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // Thay đổi locale trong EasyLocalization
      await context.setLocale(locale);

      // Lưu vào local storage
      final saved = await await prefs.setString('locale', locale.toString());
      ;

      // Emit to stream
      _localeStreamController.add(locale);

      if (kDebugMode) {
        print('Changed locale to: $locale, saved: $saved');
      }

      return saved;
    } catch (e) {
      if (kDebugMode) {
        print('Error changing locale: $e');
      }
      return false;
    }
  }

  String _getFlagEmoji(String languageCode) {
    const flags = {
      'en': '🇺🇸',
      'vi': '🇻🇳',
      'ja': '🇯🇵',
      'ko': '🇰🇷',
      'zh': '🇨🇳',
      'es': '🇪🇸',
      'fr': '🇫🇷',
      'de': '🇩🇪',
      'it': '🇮🇹',
      'pt': '🇵🇹',
      'ru': '🇷🇺',
      'ar': '🇸🇦',
      'hi': '🇮🇳',
      'th': '🇹🇭',
    };
    return flags[languageCode] ?? '🌐';
  }

  void dispose() {
    _localeStreamController.close();
  }
}

// Model class cho locale info
