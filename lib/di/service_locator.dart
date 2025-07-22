import 'package:get_it/get_it.dart';
import 'package:numbers/new_screens/test_rank/service.dart';
import 'package:numbers/provider/BlockDataStream.dart';
import 'package:numbers/service/leader_board_service.dart';
import 'package:numbers/service/score_service.dart';
import 'package:numbers/service/sound_service.dart';
import 'package:numbers/service/main_store_service.dart';
import 'package:numbers/service/test_board.dart';
import 'package:numbers/utils/game_config.dart';

final getIt = GetIt.instance;

Future<void> setupLocator() async {
  getIt.registerSingleton<GameConfig>(
      GameConfig.fromDifficulty(GameDifficulty.easy));
  getIt.registerSingleton<BlockDataStream>(
    BlockDataStream(),
  );
  getIt.registerSingleton<MainSoundService>(MainSoundService());
  getIt.registerSingleton<ScoreService>(ScoreService());
  getIt.registerSingleton<MainStoreService>(MainStoreService());
  getIt.registerSingleton<LeaderBoardService>(LeaderBoardService());
  getIt.registerSingleton<LeaderBoardServiceTest>(LeaderBoardServiceTest());
  getIt.registerSingleton<Service>(Service());
}
