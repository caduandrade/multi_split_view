import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:multi_split_view/multi_split_view.dart';

void main() => runApp(MultiSplitViewExampleApp());

class MultiSplitViewExampleApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MultiSplitViewExample(),
    );
  }
}

class MultiSplitViewExample extends StatefulWidget {
  final List<Color> _colors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.purple,
    Colors.brown,
    Colors.pinkAccent
  ];

  @override
  _MultiSplitViewExampleState createState() => _MultiSplitViewExampleState();
}

class _MultiSplitViewExampleState extends State<MultiSplitViewExample> {
  int _horizontalVisibleWidgets = 3;

  @override
  Widget build(BuildContext context) {
    int max = widget._colors.length;
    Widget buttons = Container(
        child: Row(children: [
          Text('Horizontal widgets: $_horizontalVisibleWidgets / $max'),
          SizedBox(width: 16),
          ElevatedButton(child: Text('Add'), onPressed: _onAddButtonClick),
          SizedBox(width: 16),
          ElevatedButton(child: Text('Remove'), onPressed: _onRemoveButtonClick)
        ], crossAxisAlignment: CrossAxisAlignment.center),
        color: Colors.white,
        padding: EdgeInsets.all(8));

    List<Widget> children = List.empty(growable: true);
    for (int i = 0; i < _horizontalVisibleWidgets; i++) {
      Widget view = Container(
        width: 300,
        height: 300,
        child: Center(child: Text("View " + (i + 1).toString())),
        color: widget._colors[i],
      );
      children.add(view);
    }

    MultiSplitView multiSplitView = MultiSplitView(
        children: children,
        controller: MultiSplitViewController(weights: [0.1]),
        onSizeChange: _onSizeChange);

    return Scaffold(
        appBar: AppBar(title: Text('Multi Split View Example')),
        body: Column(children: [buttons, Expanded(child: multiSplitView)])
        // body: horizontal,
        );
  }

  _onSizeChange(int childIndex1, int childIndex2) {
    print('change - childIndex1: $childIndex1 - childIndex2: $childIndex2');
  }

  _onRemoveButtonClick() {
    setState(() {
      _horizontalVisibleWidgets = max(0, _horizontalVisibleWidgets - 1);
    });
  }

  _onAddButtonClick() {
    setState(() {
      _horizontalVisibleWidgets =
          min(widget._colors.length, _horizontalVisibleWidgets + 1);
    });
  }
}
