import 'package:demoflu/demoflu.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

abstract class ExampleWidget extends DemoStatelessWidget {
  final List<Color> colors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.purple,
    Colors.brown,
    Colors.pinkAccent
  ];
  Widget buildContent(int number) {
    return Container(
      child: Center(child: Text(number.toString())),
      color: colors[number],
    );
  }
}
