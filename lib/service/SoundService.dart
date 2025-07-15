import 'package:audioplayers/audioplayers.dart';
import 'package:vibration/vibration.dart';
import 'package:numbers/store/SettingsStore.dart';

class SoundService {
  static final SoundService _instance = SoundService._internal();
  factory SoundService() => _instance;
  SoundService._internal();

  late AudioPlayer _audioPlayer;
  late AudioPlayer _musicPlayer;
  bool _isInitialized = false;

  // Sound effects
  static const String _blockSelectSound = 'block_select.mp3';
  static const String _correctSound = 'correct.mp3';
  static const String _wrongSound = 'wrong.mp3';
  static const String _hintSound = 'hint.mp3';
  static const String _powerUpSound = 'powerup.mp3';
  static const String _levelCompleteSound = 'level_complete.mp3';
  static const String _gameOverSound = 'game_over.mp3';
  static const String _buttonClickSound = 'button_click.mp3';
  static const String _achievementSound = 'achievement.mp3';

  // Background music
  static const String _backgroundMusic = 'background_music.mp3';

  Future<void> initialize() async {
    if (_isInitialized) return;

    _audioPlayer = AudioPlayer();
    _musicPlayer = AudioPlayer();
    _isInitialized = true;
  }

  Future<void> dispose() async {
    if (_isInitialized) {
      await _audioPlayer.dispose();
      await _musicPlayer.dispose();
      _isInitialized = false;
    }
  }

  // Play sound effects
  Future<void> playBlockSelect() async {
    if (!SettingsStore.instance.sound) return;
    await _playSound(_blockSelectSound);
    await _hapticFeedback(HapticFeedback.lightImpact);
  }

  Future<void> playCorrect() async {
    if (!SettingsStore.instance.sound) return;
    await _playSound(_correctSound);
    await _hapticFeedback(HapticFeedback.mediumImpact);
  }

  Future<void> playWrong() async {
    if (!SettingsStore.instance.sound) return;
    await _playSound(_wrongSound);
    await _hapticFeedback(HapticFeedback.heavyImpact);
  }

  Future<void> playHint() async {
    if (!SettingsStore.instance.sound) return;
    await _playSound(_hintSound);
    await _hapticFeedback(HapticFeedback.selectionClick);
  }

  Future<void> playPowerUp() async {
    if (!SettingsStore.instance.sound) return;
    await _playSound(_powerUpSound);
    await _hapticFeedback(HapticFeedback.mediumImpact);
  }

  Future<void> playLevelComplete() async {
    if (!SettingsStore.instance.sound) return;
    await _playSound(_levelCompleteSound);
    await _hapticFeedback(HapticFeedback.heavyImpact);
  }

  Future<void> playGameOver() async {
    if (!SettingsStore.instance.sound) return;
    await _playSound(_gameOverSound);
    await _hapticFeedback(HapticFeedback.heavyImpact);
  }

  Future<void> playButtonClick() async {
    if (!SettingsStore.instance.sound) return;
    await _playSound(_buttonClickSound);
    await _hapticFeedback(HapticFeedback.selectionClick);
  }

  Future<void> playAchievement() async {
    if (!SettingsStore.instance.sound) return;
    await _playSound(_achievementSound);
    await _hapticFeedback(HapticFeedback.heavyImpact);
  }

  // Background music
  Future<void> playBackgroundMusic() async {
    if (!SettingsStore.instance.sound) return;
    try {
      await _musicPlayer.play(AssetSource(_backgroundMusic));
      await _musicPlayer.setReleaseMode(ReleaseMode.loop);
      await _musicPlayer.setVolume(0.3);
    } catch (e) {
      // Background music file might not exist yet
      print('Background music not found: $e');
    }
  }

  Future<void> stopBackgroundMusic() async {
    await _musicPlayer.stop();
  }

  Future<void> pauseBackgroundMusic() async {
    await _musicPlayer.pause();
  }

  Future<void> resumeBackgroundMusic() async {
    if (!SettingsStore.instance.sound) return;
    await _musicPlayer.resume();
  }

  // Private methods
  Future<void> _playSound(String soundFile) async {
    try {
      await _audioPlayer.play(AssetSource(soundFile));
      await _audioPlayer.setVolume(0.7);
    } catch (e) {
      // Sound file might not exist yet
      print('Sound file not found: $soundFile - $e');
    }
  }

  Future<void> _hapticFeedback(HapticFeedbackType type) async {
    if (!SettingsStore.instance.vibration) return;

    if (await Vibration.hasVibrator()) {
      switch (type) {
        case HapticFeedback.lightImpact:
          Vibration.vibrate(duration: 50);
          break;
        case HapticFeedback.mediumImpact:
          Vibration.vibrate(duration: 100);
          break;
        case HapticFeedback.heavyImpact:
          Vibration.vibrate(duration: 200);
          break;
        case HapticFeedback.selectionClick:
          Vibration.vibrate(duration: 30);
          break;
      }
    }
  }
}

// Haptic feedback types
class HapticFeedback {
  static const lightImpact = HapticFeedbackType.lightImpact;
  static const mediumImpact = HapticFeedbackType.mediumImpact;
  static const heavyImpact = HapticFeedbackType.heavyImpact;
  static const selectionClick = HapticFeedbackType.selectionClick;
}

enum HapticFeedbackType {
  lightImpact,
  mediumImpact,
  heavyImpact,
  selectionClick,
}
