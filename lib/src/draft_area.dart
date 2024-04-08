import 'dart:math';

import 'package:flutter/material.dart';

/// A sample widget used to demonstrate the usage of a split area
/// within a layout. This widget is intended for demonstration purposes
/// only during development and should not be used in production.
class DraftArea extends StatelessWidget {
  const DraftArea(this.text, this.color, {Key? key}) : super(key: key);

  factory DraftArea.blue(String text, {Key? key}) {
    return DraftArea(text, Colors.blue[300]!, key: key);
  }

  factory DraftArea.yellow(String text, {Key? key}) {
    return DraftArea(text, Colors.yellow[400]!, key: key);
  }

  factory DraftArea.green(String text, {Key? key}) {
    return DraftArea(text, Colors.green[300]!, key: key);
  }

  factory DraftArea.brown(String text, {Key? key}) {
    return DraftArea(text, Colors.brown, key: key);
  }

  factory DraftArea.pink(String text, {Key? key}) {
    return DraftArea(text, Colors.pink[300]!, key: key);
  }

  factory DraftArea.orange(String text, {Key? key}) {
    return DraftArea(text, Colors.orange[300]!, key: key);
  }

  factory DraftArea.teal(String text, {Key? key}) {
    return DraftArea(text, Colors.teal[300]!, key: key);
  }

  factory DraftArea.random(String text, {Key? key}) {
    Random random = Random();
    return DraftArea(
        text,
        Color.fromARGB(
            255, random.nextInt(255), random.nextInt(255), random.nextInt(255)),
        key: key);
  }

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
        color: color,
        child: Placeholder(
            color: _invert(color, 20),
            child: Center(
                child: Text(text,
                    style: TextStyle(
                        color: _invert(color, 255),
                        fontWeight: FontWeight.bold)))));
  }

  Color _invert(Color color, int alpha) {
    final r = 255 - color.red;
    final g = 255 - color.green;
    final b = 255 - color.blue;

    return Color.fromARGB(alpha, r, g, b);
  }
}
