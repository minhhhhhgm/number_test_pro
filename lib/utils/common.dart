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
    if (low == high) return low;
    return low + Random().nextInt(high - low);
  }

  static Color getRandomColor() {
    return list[Common.getRandomNumber(min: 0, max: list.length)];
  }

  static List<int> findCombination({required int value, required int length}) {
    List<int> combinations = [];
    int remaining = value;

    for (int i = 0; i < length - 1; i++) {
      int max = remaining - (length - i - 1);
      int val = getRandomNumber(min: 1, max: max);
      combinations.add(val);
      remaining -= val;
    }

    combinations.add(remaining);
    combinations.shuffle();

    return combinations;
  }

  // static findCombination(int value, int length) {
  //   List<int> combinations = [];
  //   int remainingCredit = value;

  //   bool breakLoop = false;
  //   int counter = 0;

  //   while (!breakLoop) {
  //     int randomValue = (counter == length - 1)
  //         ? remainingCredit
  //         : getRandomNumber(min: 1, max: remainingCredit);
  //     combinations.add(randomValue);
  //     remainingCredit -= randomValue;
  //     counter++;
  //     if (remainingCredit < 0 || remainingCredit == 0) {
  //       breakLoop = true;
  //     }
  //   }

  //   return combinations;
  // }

  static List<int> fillWithRandomValues(
      {required List<int> combinations, required int max, required int size}) {
    List<int> result = List.from(combinations);

    while (result.length < size) {
      int random = getRandomNumber(min: 1, max: max);
      if (!result.contains(random)) {
        result.add(random);
      }
    }

    result.shuffle();
    return result;
  }

  static String getRandomName() {
    return faker.Faker().person.name();
  }
}
