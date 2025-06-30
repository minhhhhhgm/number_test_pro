import 'package:numbers/utils/Common.dart';
import 'package:flutter/material.dart';

class BlockSchema {
  late int value, index, target;
  bool isSelected = false;
  late Color color;
  final int size = 6;
  late List<int> blockValues;

  BlockSchema() {
    generateTargetValue();
    generateValues();
  }

  void generateTargetValue() {
    target = Common.getRandomNumber(min: 4, max: 999);
  }

  void generateValues() {
    List<int> combinations = Common.findCombination(this.target, 3);
    this.blockValues =
        Common.fillWithRandomValues(combinations, this.target * 2, size);
  }

  BlockSchema.build(
      {required this.color, required this.index, required this.value});

  List<BlockSchema> getBlocks() {
    List<BlockSchema> blocksList = [];

    for (var i = 0; i < this.size; i++) {
      blocksList.add(
        BlockSchema.build(
            color: Common.getRandomColor(),
            index: i,
            value: this.blockValues[i]),
      );
    }

    return blocksList;
  }
}
