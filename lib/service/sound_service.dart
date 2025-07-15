import 'package:audio_session/audio_session.dart';
import 'package:just_audio/just_audio.dart';

class MainSoundService {
  static final MainSoundService _instance = MainSoundService._internal();
  factory MainSoundService() => _instance;
  MainSoundService._internal();

  late final AudioPlayer _musicPlayer;
  late final AudioPlayer _effectPlayer;
  bool isPlaying = false;

  static const String _backgroundMusic = 'assets/sounds/sound_bg.mp3';
  static const String _correctSound = 'assets/sounds/correct.mp3';
  static const String _incorrectSound = 'assets/sounds/incorrect.mp3';

  Future<void> init() async {
    // Init session
    final session = await AudioSession.instance;
    await session.configure(AudioSessionConfiguration.music());

    _musicPlayer = AudioPlayer();
    _effectPlayer = AudioPlayer();
  }

  Future<void> playBackgroundMusic() async {
    try {
      await _musicPlayer.setAsset(_backgroundMusic);
      await _musicPlayer.setLoopMode(LoopMode.one);
      await _musicPlayer.setVolume(0.5);
      await _musicPlayer.play();
      isPlaying = true;
    } catch (e) {
      print('Error playing background music: $e');
    }
  }

  Future<void> stopBackgroundMusic() async {
    isPlaying = false;
    await _musicPlayer.stop();
  }

  Future<void> pauseBackgroundMusic() async {
    await _musicPlayer.pause();
    isPlaying = false;
  }

  Future<void> resumeBackgroundMusic() async {
    if (!isPlaying) {
      await _musicPlayer.play();
      isPlaying = true;
    }
  }

  Future<void> playCorrectSound() async {
    await _effectPlayer.setAsset(_correctSound);
    await _effectPlayer.setVolume(1.0);
    await _effectPlayer.play();
  }

  Future<void> playIncorrectSound() async {
    await _effectPlayer.setAsset(_incorrectSound);
    await _effectPlayer.setVolume(1.0);
    await _effectPlayer.play();
  }

  Future<void> dispose() async {
    await _musicPlayer.dispose();
    await _effectPlayer.dispose();
    isPlaying = false;
  }
}
