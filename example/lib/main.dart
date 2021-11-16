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
  final int _max = 40;
  int _horizontalVisibleWidgets = 3;
  MultiSplitViewController? _c;

  @override
  Widget build(BuildContext context) {
    Widget buttons = Container(
        child: Row(children: [
          Text('Horizontal widgets: $_horizontalVisibleWidgets / $_max'),
          SizedBox(width: 16),
          ElevatedButton(child: Text('rebuild'), onPressed: _onAddButtonClick),
          SizedBox(width: 16),
          ElevatedButton(child: Text('new controller e rebuild'), onPressed: _onRemoveButtonClick)
        ], crossAxisAlignment: CrossAxisAlignment.center),
        color: Colors.white,
        padding: EdgeInsets.all(8));

    List<Widget> children = List.empty(growable: true);
    for (int i = 0; i < _horizontalVisibleWidgets; i++) {
      Widget view = Container(
        child: Center(child: TextFormField(controller: TextEditingController(text: "View " + (i + 1).toString()))),
        color: widget._colors[i % widget._colors.length],
      );
      children.add(view);
    }



    MultiSplitView multiSplitView = MultiSplitView(initialWeights: [.05],
        children: children,
        controller: _c,
        onSizeChange: _onSizeChange);

    MultiSplitViewTheme theme = MultiSplitViewTheme(
        child: multiSplitView,
        data: MultiSplitViewThemeData(
            dividerPainter: DividerPainters.grooved1()));

    return Scaffold(
        appBar: AppBar(title: Text('Multi Split View Example')),
        body: Column(children: [buttons, Expanded(child: theme)])
        // body: horizontal,
        );
  }

  _onSizeChange(int childIndex1, int childIndex2) {
    // print('change - childIndex1: $childIndex1 - childIndex2: $childIndex2');
  }

  _onRemoveButtonClick() {
    setState(() {
      _c=MultiSplitViewController();
      //_horizontalVisibleWidgets = max(0, _horizontalVisibleWidgets - 1);
    });
  }

  _onAddButtonClick() {
    setState(() {
      //_horizontalVisibleWidgets = min(_max, _horizontalVisibleWidgets + 1);
    });
  }
}
