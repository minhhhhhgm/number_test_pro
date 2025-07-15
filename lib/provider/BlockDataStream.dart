import 'dart:async';
import 'dart:developer';

class BlockDataStream {
  final _controller = StreamController<Map<String, int>>.broadcast();

  final _scoreController = StreamController<int>.broadcast();

  void setCount({required int index, required int value}) {
    _controller.sink.add({"index": index, "value": value});
  }

  void setScore({required int score}) {
    log('setScore stream');
    _scoreController.sink.add(score);
  }

  void dispose() {
    _controller.close();
    _scoreController.close();
  }

  Stream<Map<String, int>> get stream => _controller.stream;

  Stream<int> get scoreStream => _scoreController.stream;
}
