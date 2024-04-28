import 'dart:math';

import 'package:flutter/material.dart';

/// A sample widget used to demonstrate the usage of a split area
/// within a layout. This widget is intended for demonstration purposes
/// only during development and should not be used in production.
class Draft extends StatelessWidget {
  const Draft(
      {required this.text,
      required this.color,
      required this.borderColor,
      Key? key})
      : super(key: key);

  factory Draft.blue({String text = 'blue', Key? key}) {
    return Draft(
        text: text,
        color: Colors.blue[300]!,
        borderColor: Colors.blue[700]!,
        key: key);
  }

  factory Draft.yellow({String text = 'yellow', Key? key}) {
    return Draft(
        text: text,
        color: Colors.yellow[300]!,
        borderColor: Colors.yellow[700]!,
        key: key);
  }

  factory Draft.green({String text = 'green', Key? key}) {
    return Draft(
        text: text,
        color: Colors.green[300]!,
        borderColor: Colors.green[700]!,
        key: key);
  }

  factory Draft.brown({String text = 'brown', Key? key}) {
    return Draft(
        text: text,
        color: Colors.brown[300]!,
        borderColor: Colors.brown[700]!,
        key: key);
  }

  factory Draft.pink({String text = 'pink', Key? key}) {
    return Draft(
        text: text,
        color: Colors.pink[300]!,
        borderColor: Colors.pink[700]!,
        key: key);
  }

  factory Draft.orange({String text = 'orange', Key? key}) {
    return Draft(
        text: text,
        color: Colors.orange[300]!,
        borderColor: Colors.orange[700]!,
        key: key);
  }

  factory Draft.teal({String text = 'teal', Key? key}) {
    return Draft(
        text: text,
        color: Colors.teal[300]!,
        borderColor: Colors.teal[700]!,
        key: key);
  }

  factory Draft.random(String text, {Key? key}) {
    Random random = Random();
    return Draft(
        text: text,
        color: Color.fromARGB(
            255, random.nextInt(255), random.nextInt(255), random.nextInt(255)),
        borderColor: Color.fromARGB(
            255, random.nextInt(255), random.nextInt(255), random.nextInt(255)),
        key: key);
  }

  final String text;
  final Color color;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
            color: color, border: Border.all(color: borderColor, width: 1)),
        child:
            Center(child: Text(text, style: TextStyle(color: Colors.black))));
  }
}
