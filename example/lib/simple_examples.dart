import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:multi_split_view/multi_split_view.dart';

void main() => runApp(SimpleExamplesApp());

class SimpleExamplesApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          primaryColor: Color(0xff393e46),
          primaryColorDark: Color(0xff222831),
          accentColor: Colors.yellow,
          buttonTheme: ButtonThemeData(
            buttonColor: Colors.red,
          )),
      home: SimpleExamples(),
    );
  }
}

class SimpleExamples extends StatefulWidget {
  final List<Color> _colors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.purple,
    Colors.brown,
    Colors.pinkAccent
  ];

  @override
  _SimpleExamplesState createState() => _SimpleExamplesState();
}

enum Example {
  horizontal,
  horizontal_with_weight,
  change_size,
  vertical,
  horizontal_vertical,
  divider_color,
  divider_thickness,
  minimal_weight
}

extension ParseToString on Example {
  String name() {
    return this.toString().split('.').last;
  }
}

class _SimpleExamplesState extends State<SimpleExamples> {
  Example _example = Example.horizontal;

  @override
  Widget build(BuildContext context) {
    List<Widget> buttons = List.empty(growable: true);
    Example.values.forEach((example) {
      buttons.add(_buildButton(example));
    });
    Widget menu = Container(
        padding: EdgeInsets.all(16),
        child: SingleChildScrollView(child: Column(children: buttons)),
        color: Colors.white);
    return Scaffold(
        key: Key(_example.name()),
        body: Row(
          children: [
            menu,
            Expanded(
                child: Container(
                    child: Center(
                        child: SizedBox(
                            child: _buildExample(), width: 400, height: 300)),
                    padding: EdgeInsets.all(16),
                    color: Colors.white))
          ],
          crossAxisAlignment: CrossAxisAlignment.stretch,
        )
        // body: horizontal,
        );
  }

  Widget _buildExample() {
    print(_example);
    if (_example == Example.horizontal) {
      return _horizontal();
    } else if (_example == Example.horizontal_with_weight) {
      return _horizontal_with_weight();
    } else if (_example == Example.change_size) {
      return _change_size();
    } else if (_example == Example.vertical) {
      return _vertical();
    } else if (_example == Example.horizontal_vertical) {
      return _horizontal_vertical();
    } else if (_example == Example.divider_color) {
      return _dividercolor();
    } else if (_example == Example.divider_thickness) {
      return _dividerthickness();
    } else if (_example == Example.minimal_weight) {
      return _minimalweight();
    }
    return Center(child: Text('?'));
  }

  Widget _horizontal() {
    Widget child1 = _buildContent(1);
    Widget child2 = _buildContent(2);
    Widget child3 = _buildContent(3);
    return MultiSplitView(children: [child1, child2, child3]);
  }

  Widget _horizontal_with_weight() {
    Widget child1 = _buildContent(1);
    Widget child2 = _buildContent(2);
    Widget child3 = _buildContent(3);
    // setting 10% of weight for the first child
    return MultiSplitView(
        children: [child1, child2, child3],
        controller: MultiSplitViewController(weights: [0.1]));
  }

  Widget _change_size() {
    Widget child1 = _buildContent(1);
    Widget child2 = _buildContent(2);
    return MultiSplitView(
        children: [child1, child2],
        onSizeChange: (childIndex1, childIndex2) => print(
            'Index of children who changed size: $childIndex1 and $childIndex2'));
  }

  Widget _vertical() {
    Widget child1 = _buildContent(1);
    Widget child2 = _buildContent(2);
    return MultiSplitView(axis: Axis.vertical, children: [child1, child2]);
  }

  Widget _horizontal_vertical() {
    Widget child1 = _buildContent(1);
    Widget child2 = _buildContent(2);
    Widget child3 = _buildContent(3);
    Widget child4 = _buildContent(4);
    return MultiSplitView(axis: Axis.vertical, children: [
      MultiSplitView(children: [child1, child2, child3]),
      child4
    ]);
  }

  Widget _dividercolor() {
    Widget child1 = _buildContent(1);
    Widget child2 = _buildContent(2);
    return MultiSplitView(
        children: [child1, child2], dividerColor: Colors.black);
  }

  Widget _dividerthickness() {
    Widget child1 = _buildContent(1);
    Widget child2 = _buildContent(2);
    Widget child3 = _buildContent(3);
    return MultiSplitView(
        children: [child1, child2, child3], dividerThickness: 30);
  }

  Widget _minimalweight() {
    Widget child1 = _buildContent(1);
    Widget child2 = _buildContent(2);
    Widget child3 = _buildContent(3);
    Widget child4 = _buildContent(4);
    return MultiSplitView(axis: Axis.vertical, children: [
      MultiSplitView(children: [child1, child2], minimalWeight: .40),
      MultiSplitView(children: [child3, child4])
    ]);
  }

  Widget _buildContent(int number) {
    return Container(
      child: Center(child: Text(number.toString())),
      color: widget._colors[number],
    );
  }

  TextButton _buildButton(Example example) {
    return TextButton(
        child: Text(example.name()),
        onPressed: () {
          print('button: ' + example.name());
          if (_example != example) {
            setState(() {
              _example = example;
            });
          }
        });
  }
}
