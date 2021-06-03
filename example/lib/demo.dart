import 'dart:core';

import 'package:flutter/material.dart';
import 'package:multi_split_view/multi_split_view.dart';

void main() => runApp(MultiSplitViewDemo());

typedef MenuItemWidgetBuilder = Widget Function();

class MenuItem {
  MenuItem(this.name, this.builder);

  final String name;
  final MenuItemWidgetBuilder builder;
}

class MultiSplitViewDemo extends StatelessWidget {
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

class _SimpleExamplesState extends State<SimpleExamples> {
  late List<MenuItem> _menuItems;
  MenuItem? _currentMenuItem;

  @override
  void initState() {
    super.initState();
    _menuItems = [
      MenuItem('Horizontal', _horizontalExample),
      MenuItem('Horizontal with weight', _horizontalWithWeightExample),
      MenuItem('Change size', _changeSizeExample),
      MenuItem('Vertical', _verticalExample),
      MenuItem('Horizontal and vertical', _horizontalVerticalExample),
      MenuItem('Divider color', _dividerColorExample),
      MenuItem('Divider color - transparent child',
          _dividerColorTransparentChildExample),
      MenuItem('Divider thickness', _dividerThicknessExample),
      MenuItem('Minimal weight', _minimalWeightExample),
      MenuItem('Minimal size', _minimalSizeExample)
    ];
    _currentMenuItem = _menuItems.first;
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> buttons = [];
    _menuItems.forEach((example) {
      buttons.add(_buildButton(example));
    });
    Widget menu = Container(
        padding: EdgeInsets.all(16),
        child: SingleChildScrollView(child: Column(children: buttons)),
        color: Colors.white);
    return Scaffold(
        key: Key(_currentMenuItem!.name),
        body: Row(
          children: [
            menu,
            Expanded(
                child: Container(
                    child: Center(
                        child: SizedBox(
                            child: _currentMenuItem!.builder(),
                            width: 400,
                            height: 300)),
                    padding: EdgeInsets.all(16),
                    color: Colors.white))
          ],
          crossAxisAlignment: CrossAxisAlignment.stretch,
        )
        // body: horizontal,
        );
  }

  Widget _horizontalExample() {
    Widget child1 = _buildContent(1);
    Widget child2 = _buildContent(2);
    Widget child3 = _buildContent(3);
    return MultiSplitView(children: [child1, child2, child3]);
  }

  Widget _horizontalWithWeightExample() {
    Widget child1 = _buildContent(1);
    Widget child2 = _buildContent(2);
    Widget child3 = _buildContent(3);
    // setting 10% of weight for the first child
    return MultiSplitView(
        children: [child1, child2, child3],
        controller: MultiSplitViewController(weights: [0.1]));
  }

  Widget _changeSizeExample() {
    Widget child1 = _buildContent(1);
    Widget child2 = _buildContent(2);
    return MultiSplitView(
        children: [child1, child2],
        onSizeChange: (childIndex1, childIndex2) => print(
            'Index of children who changed size: $childIndex1 and $childIndex2'));
  }

  Widget _verticalExample() {
    Widget child1 = _buildContent(1);
    Widget child2 = _buildContent(2);
    return MultiSplitView(axis: Axis.vertical, children: [child1, child2]);
  }

  Widget _horizontalVerticalExample() {
    Widget child1 = _buildContent(1);
    Widget child2 = _buildContent(2);
    Widget child3 = _buildContent(3);
    Widget child4 = _buildContent(4);
    return MultiSplitView(axis: Axis.vertical, children: [
      MultiSplitView(children: [child1, child2, child3]),
      child4
    ]);
  }

  Widget _dividerColorExample() {
    Widget child1 = _buildContent(1);
    Widget child2 = _buildContent(2);
    return MultiSplitView(
        children: [child1, child2], dividerColor: Colors.black);
  }

  Widget _dividerColorTransparentChildExample() {
    Widget child1 = Center(child: Text('A'));
    Widget child2 = Center(child: Text('B'));
    return MultiSplitView(
        children: [child1, child2], dividerColor: Colors.yellow);
  }

  Widget _dividerThicknessExample() {
    Widget child1 = _buildContent(1);
    Widget child2 = _buildContent(2);
    Widget child3 = _buildContent(3);
    return MultiSplitView(
        children: [child1, child2, child3], dividerThickness: 30);
  }

  Widget _minimalWeightExample() {
    Widget child1 = _buildContent(1);
    Widget child2 = _buildContent(2);
    Widget child3 = _buildContent(3);
    Widget child4 = _buildContent(4);
    return MultiSplitView(axis: Axis.vertical, children: [
      MultiSplitView(children: [child1, child2], minimalWeight: .40),
      MultiSplitView(children: [child3, child4])
    ]);
  }

  Widget _minimalSizeExample() {
    Widget child1 = _buildContent(1);
    Widget child2 = _buildContent(2);
    Widget child3 = _buildContent(3);
    Widget child4 = _buildContent(4);
    return MultiSplitView(axis: Axis.vertical, children: [
      MultiSplitView(children: [child1, child2], minimalSize: 100),
      MultiSplitView(children: [child3, child4])
    ]);
  }

  Widget _buildContent(int number) {
    return Container(
      child: Center(child: Text(number.toString())),
      color: widget._colors[number],
    );
  }

  TextButton _buildButton(MenuItem newMenuItem) {
    return TextButton(
        child: Text(newMenuItem.name),
        onPressed: () {
          if (_currentMenuItem != newMenuItem) {
            setState(() {
              _currentMenuItem = newMenuItem;
            });
          }
        });
  }
}
