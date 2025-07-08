import 'package:numbers/utils/Common.dart';
import 'package:flutter/material.dart';

class BlockSchema {
  late int value, index, target;
  bool isSelected = false;
  late Color color;
  final int size = 9;
  late List<int> blockValues;

  BlockSchema() {
    generateTargetValue();
    generateValues();
  }

  void generateTargetValue() {
    target = Common.getRandomNumber(min: 0, max: 999);
  }

  void generateValues() {
    List<int> combinations = Common.findCombination(target, 3);
    blockValues =
        Common.fillWithRandomValues(combinations, target * 2, size);
  }

  BlockSchema.build(
      {required this.color, required this.index, required this.value});

  List<BlockSchema> getBlocks() {
    List<BlockSchema> blocksList = [];

    for (var i = 0; i < size; i++) {
      blocksList.add(
        BlockSchema.build(
            color: Common.getRandomColor(),
            index: i,
            value: blockValues[i]),
      );
    }

    return blocksList;
  }
}
