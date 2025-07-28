import 'dart:math';

import 'package:audio_session/audio_session.dart';
import 'package:just_audio/just_audio.dart';
import 'package:numbers/di/service_locator.dart';
import 'package:numbers/utils/game_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainSoundService {
  static final MainSoundService _instance = MainSoundService._internal();
  factory MainSoundService() => _instance;
  MainSoundService._internal();

  late final AudioPlayer _musicPlayer;
  late final AudioPlayer _effectPlayer;
  bool isPlaying = false;

  late bool isSoundEnable;

  final List<String> _wrongSounds = List.generate(
    7,
    (index) => 'assets/sounds/wrong$index.mp3',
  );
  final List<String> _correctSounds = List.generate(
    5,
    (index) => 'assets/sounds/correct$index.mp3',
  );

  Future<void> init() async {
    // Init session
    final session = await AudioSession.instance;
    await session.configure(AudioSessionConfiguration.music());
    final prefs = await SharedPreferences.getInstance();
    final isSoundEnableStore = await prefs.getBool('isSoundEnable');
    if (isSoundEnableStore == null) {
      await prefs.setBool('isSoundEnable', true);
      isSoundEnable = await prefs.getBool('isSoundEnable')!;
    } else {
      isSoundEnable = await prefs.getBool('isSoundEnable')!;
    }
    _musicPlayer = AudioPlayer();
    _effectPlayer = AudioPlayer();
  }

  Future<void> updateConfigSounds(bool isSoundEnable) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isSoundEnable', isSoundEnable);
  }

  Future<void> playBackgroundMusic() async {
    final prefs = await SharedPreferences.getInstance();
    isSoundEnable = await prefs.getBool('isSoundEnable')!;
    if (!isSoundEnable) return;

    final config = getIt<GameConfig>();
    final gameMode = config.gameMode;
    String backgroundPath = 'assets/sounds/backgound_easy.mp3';

    if (gameMode == GameDifficulty.easy) {
      backgroundPath = 'assets/sounds/backgound_easy.mp3';
    }
    if (gameMode == GameDifficulty.normal) {
      backgroundPath = 'assets/sounds/back_ground3.mp3';
    }

    if (gameMode == GameDifficulty.hard) {
      backgroundPath = 'assets/sounds/background_hard.mp3';
    }

    if (gameMode == GameDifficulty.crazy) {
      backgroundPath = 'assets/sounds/back_ground_normal.mp3';
    }

    try {
      await _musicPlayer.setAsset(backgroundPath);
      await _musicPlayer.setLoopMode(LoopMode.one);
      await _musicPlayer.setVolume(0.3);
      await _musicPlayer.play();
      isPlaying = true;
    } catch (e) {
      print('Error playing background music: $e');
    }
  }

  Future<void> stopBackgroundMusic() async {
    final prefs = await SharedPreferences.getInstance();
    isSoundEnable = await prefs.getBool('isSoundEnable')!;
    if (!isSoundEnable) return;

    isPlaying = false;
    await _musicPlayer.stop();
  }

  Future<void> playRankingMusic() async {
    final prefs = await SharedPreferences.getInstance();
    isSoundEnable = await prefs.getBool('isSoundEnable')!;
    if (!isSoundEnable) return;

    String backgroundPath = 'assets/sounds/ranking.mp3';

    try {
      await _musicPlayer.setAsset(backgroundPath);
      await _musicPlayer.setLoopMode(LoopMode.one);
      await _musicPlayer.setVolume(0.3);
      await _musicPlayer.play();
      isPlaying = true;
    } catch (e) {
      print('Error playing background music: $e');
    }
  }

  Future<void> stopRankingMusic() async {
    final prefs = await SharedPreferences.getInstance();
    isSoundEnable = await prefs.getBool('isSoundEnable')!;
    if (!isSoundEnable) return;

    isPlaying = false;
    await _musicPlayer.stop();
  }

  Future<void> pauseBackgroundMusic() async {
    final prefs = await SharedPreferences.getInstance();
    isSoundEnable = await prefs.getBool('isSoundEnable')!;
    if (!isSoundEnable) return;

    await _musicPlayer.pause();
    isPlaying = false;
  }

  Future<void> resumeBackgroundMusic() async {
    final prefs = await SharedPreferences.getInstance();
    isSoundEnable = await prefs.getBool('isSoundEnable')!;
    if (!isSoundEnable) return;

    if (!isPlaying) {
      await _musicPlayer.play();
      isPlaying = true;
    }
  }

  Future<void> playCorrectSound() async {
    final prefs = await SharedPreferences.getInstance();
    isSoundEnable = await prefs.getBool('isSoundEnable')!;
    if (!isSoundEnable) return;

    final random = Random();
    final randomIndex = random.nextInt(_correctSounds.length); // 0 -> 8
    final selectedSound = _correctSounds[randomIndex];

    try {
      await _effectPlayer.setAsset(selectedSound);
      await _effectPlayer.setVolume(2);
      await _effectPlayer.play();
    } catch (e) {
      print('Error playing incorrect sound: $e -- $randomIndex');
    }
  }

  Future<void> playIncorrectSound() async {
    final prefs = await SharedPreferences.getInstance();
    isSoundEnable = await prefs.getBool('isSoundEnable')!;
    if (!isSoundEnable) return;

    final random = Random();
    final randomIndex = random.nextInt(_wrongSounds.length); // 0 -> 8
    final selectedSound = _wrongSounds[randomIndex];

    try {
      await _effectPlayer.setAsset(selectedSound);
      await _effectPlayer.setVolume(2);
      await _effectPlayer.play();
    } catch (e) {
      print('Error playing incorrect sound: $e -- $randomIndex');
    }
  }

  Future<void> pauseEffectSound() async {
    final prefs = await SharedPreferences.getInstance();
    isSoundEnable = await prefs.getBool('isSoundEnable')!;
    if (!isSoundEnable) return;

    try {
      await _effectPlayer.stop();
    } catch (e) {
      print('Error playing incorrect sound: $e');
    }
  }

  Future<void> pauseSounds() async {
    final prefs = await SharedPreferences.getInstance();
    isSoundEnable = await prefs.getBool('isSoundEnable')!;
    if (!isSoundEnable) return;

    await _musicPlayer.pause();
    await _effectPlayer.pause();
    isPlaying = false;
  }

  Future<void> resumeSounds() async {
    final prefs = await SharedPreferences.getInstance();
    isSoundEnable = await prefs.getBool('isSoundEnable')!;
    if (!isSoundEnable) return;

    await _musicPlayer.play();
    await _effectPlayer.play();
    isPlaying = true;
  }

  Future<void> dispose() async {
    final prefs = await SharedPreferences.getInstance();
    isSoundEnable = await prefs.getBool('isSoundEnable')!;
    if (!isSoundEnable) return;

    await _musicPlayer.dispose();
    await _effectPlayer.dispose();
    isPlaying = false;
  }
}
