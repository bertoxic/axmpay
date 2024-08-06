import 'dart:math';

import 'package:flutter/material.dart';

Color getRandomColor() {
  final List<Color> _colors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.yellow,
    Colors.orange,
    Colors.purple,
    Colors.pink,
    Colors.brown,
    Colors.cyan,
    Colors.teal,
    Colors.indigo,
    Colors.lime,
  ];
  final randomIndex = Random().nextInt(_colors.length);
  return _colors[randomIndex];
}