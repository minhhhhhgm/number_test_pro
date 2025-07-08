import 'dart:math';
import 'package:faker/faker.dart' as faker;
import 'package:flutter/material.dart';

class Common {
  static final List<Color> list = [
    Colors.blue,
    Colors.pink,
    Colors.yellow,
    Colors.purple,
    Colors.orange,
    Colors.brown,
  ];

  static List<List> combo = [];

  static int getRandomNumber({required int min, required int max}) {
  final low = min < max ? min : max;
  final high = max > min ? max : min;

  return low + Random().nextInt(high - low);
}

  static Color getRandomColor() {
    return list[Common.getRandomNumber(min: 0, max: list.length)];
  }

  static findCombination(int value, int length) {
    List<int> combinations = [];
    int remainingCredit = value;

    bool breakLoop = false;
    int counter = 0;

    while (!breakLoop) {
      int randomValue = (counter == length - 1)
          ? remainingCredit
          : getRandomNumber(min: 1, max: remainingCredit);
      combinations.add(randomValue);
      remainingCredit -= randomValue;
      counter++;
      if (remainingCredit < 0 || remainingCredit == 0) {
        breakLoop = true;
      }
    }

    return combinations;
  }

  static fillWithRandomValues(List combinations, int max, int size) {
    for (var i = 0; i < size; i++) {
      if (combinations.length < size) {
        combinations.add(getRandomNumber(min: 0, max: max));
      }
    }

    combinations.shuffle();

    return combinations;
  }

  static String getRandomName() {
    return faker.Faker().person.name();
  }
}
