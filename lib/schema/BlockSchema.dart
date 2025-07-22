import 'package:equatable/equatable.dart';
import 'package:numbers/di/service_locator.dart';
import 'package:numbers/utils/Common.dart';
import 'package:flutter/material.dart';
import 'package:numbers/utils/game_config.dart';

class BlockSchema {
  late int value, index, target;
  bool isSelected = false;
  late Color color;
  final int size = 12;
  late List<int> blockValues;
  late List<int> correctCombination; // Thêm biến này
  bool isHint = false; // Thêm thuộc tính này
  bool isRevealed = false; // Thêm thuộc tính này

  BlockSchema() {
    generateTargetValue();
    generateValues();
  }

  BlockSchema.withTarget(int customTarget) {
    target = customTarget;
    generateValues();
  }

  void generateTargetValue() {
    target = Common.getRandomNumber(min: 0, max: 90);
  }

  void generateValues() {
    List<int> combinations = Common.findCombination(value: target, length: 3);
    correctCombination = List.from(combinations); // Lưu lại tổ hợp đúng
    blockValues = Common.fillWithRandomValues(
        combinations: combinations, max: target * 2, size: size);
  }

  BlockSchema.build(
      {required this.color, required this.index, required this.value});

  List<BlockSchema> getBlocks() {
    List<BlockSchema> blocksList = [];

    for (var i = 0; i < size; i++) {
      blocksList.add(
        BlockSchema.build(
            color: Common.getRandomColor(), index: i, value: blockValues[i]),
      );
    }

    return blocksList;
  }
}

final config = getIt<GameConfig>();

class BlockSchemaNew extends Equatable {
  final int value;
  final int index;
  final int target;
  final bool isSelected;
  final Color? color;
  final List<int> blockValues;
  final List<int> correctCombination;
  final bool isHint;
  final bool isRevealed;
  final bool triggerHint;

  const BlockSchemaNew(
      {this.value = 0,
      this.index = 0,
      this.target = 0,
      this.color,
      this.isSelected = false,
      this.isHint = false,
      this.isRevealed = false,
      this.blockValues = const [],
      this.correctCombination = const [],
      this.triggerHint = false});

  factory BlockSchemaNew.random() {
    final target =
        Common.getRandomNumber(min: config.minTarget, max: config.maxTarget);
    final combination = Common.findCombination(
        value: target, length: config.correctCombinationLength);
    final values = Common.fillWithRandomValues(
        combinations: combination, max: target * 2, size: config.blockSize);

    return BlockSchemaNew(
      target: target,
      color: Common.getRandomColor(),
      blockValues: values,
      correctCombination: combination,
    );
  }

  List<BlockSchemaNew> generateBlocks({int? target}) {
    return List.generate(config.blockSize, (index) {
      return BlockSchemaNew(
          value: blockValues[index],
          index: index,
          target: this.target,
          color: Color(0xFFbec697),
          blockValues: blockValues,
          correctCombination: correctCombination,
          triggerHint: false);
    });
  }

  BlockSchemaNew copyWith(
      {int? value,
      int? index,
      int? target,
      bool? isSelected,
      Color? color,
      List<int>? blockValues,
      List<int>? correctCombination,
      bool? isHint,
      bool? isRevealed,
      bool? triggerHint}) {
    return BlockSchemaNew(
        value: value ?? this.value,
        index: index ?? this.index,
        target: target ?? this.target,
        isSelected: isSelected ?? this.isSelected,
        color: color ?? this.color,
        blockValues: blockValues ?? this.blockValues,
        correctCombination: correctCombination ?? this.correctCombination,
        isHint: isHint ?? this.isHint,
        isRevealed: isRevealed ?? this.isRevealed,
        triggerHint: triggerHint ?? this.triggerHint);
  }

  @override
  List<Object?> get props => [
        value,
        index,
        target,
        isSelected,
        color,
        blockValues,
        correctCombination,
        isHint,
        isRevealed,
        triggerHint
      ];
}
