

abstract class GameEvent {}

class GameStarted extends GameEvent {
  final String gameMode;
  GameStarted({this.gameMode = ''});
}

class BlockSelected extends GameEvent {
  final int index;
  final int value;
  BlockSelected({required this.index, required this.value});
}

class PowerUpUsed extends GameEvent {
  final PowerUpType type;
  PowerUpUsed(this.type);
}

class HintUsed extends GameEvent {}

class TimerTicked extends GameEvent {}

class NextTurn extends GameEvent {}

class GameEnded extends GameEvent {}

class ValidateBlocksEvent extends GameEvent {
  final Map<String, int> blockData;

  ValidateBlocksEvent({required this.blockData});
}

enum PowerUpType {
  doubleScore,
  addTime,
  skipLevel,
  revealBlock,
}
