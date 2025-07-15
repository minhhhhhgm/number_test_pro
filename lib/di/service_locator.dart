import 'package:get_it/get_it.dart';
import 'package:numbers/provider/BlockDataStream.dart';
import 'package:numbers/service/score_service.dart';
import 'package:numbers/service/sound_service.dart';
import 'package:numbers/utils/game_config.dart';

final getIt = GetIt.instance;

void setupLocator() {
  getIt.registerSingleton<GameConfig>(
      GameConfig.fromDifficulty(GameDifficulty.easy));
  getIt.registerSingleton<BlockDataStream>(
    BlockDataStream(),
  );
  getIt.registerSingleton<MainSoundService>(MainSoundService());
  getIt.registerSingleton<ScoreService>(ScoreService());
}
