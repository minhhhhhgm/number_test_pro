import 'dart:async';

class BlockDataStream {
  final _controller = StreamController<Map<String, int>>.broadcast();

  final _scoreController = StreamController<int>.broadcast();
  final _pointController = StreamController<int>.broadcast();

  void setCount({required int index, required int value}) {
    _controller.sink.add({"index": index, "value": value});
  }

  void setScore({required int score}) {
    _scoreController.sink.add(score);
  }

  void setPoint({required int point}) {
    _pointController.sink.add(point);
  }

  void dispose() {
    _controller.close();
    _scoreController.close();
    _pointController.close();
  }

  Stream<Map<String, int>> get stream => _controller.stream;

  Stream<int> get scoreStream => _scoreController.stream;

  Stream<int> get pointStream => _pointController.stream;
}
