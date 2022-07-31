import 'dart:math';

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
  @override
  _MultiSplitViewExampleState createState() => _MultiSplitViewExampleState();
}

class _MultiSplitViewExampleState extends State<MultiSplitViewExample> {
  static const int _max = 40;
  static const int _initial = 3;

  late final List<RandomColorBox> _boxes;

  MultiSplitViewController _controller = MultiSplitViewController();

  @override
  void initState() {
    super.initState();
    _boxes = List.generate(_initial, (_) => _createBox());
  }

  @override
  Widget build(BuildContext context) {
    Widget buttons = Container(
        child: Row(children: [
          Text('Horizontal widgets: ${_boxes.length} / $_max'),
          SizedBox(width: 16),
          ElevatedButton(child: Text('Add'), onPressed: _onAddButtonClick),
          SizedBox(width: 16),
          ElevatedButton(
              child: Text('Remove'), onPressed: _onRemoveButtonClick),
          SizedBox(width: 16),
          ElevatedButton(
              child: Text('Change second area weight'),
              onPressed: _onSetWeightButtonClick)
        ], crossAxisAlignment: CrossAxisAlignment.center),
        color: Colors.white,
        padding: EdgeInsets.all(8));

    final List<Widget> children = _boxes;

    MultiSplitView multiSplitView = MultiSplitView(
        children: children,
        onWeightChange: _onWeightChange,
        controller: _controller);

    MultiSplitViewTheme theme = MultiSplitViewTheme(
        child: multiSplitView,
        data: MultiSplitViewThemeData(
            dividerPainter: DividerPainters.grooved2()));

    return Scaffold(
        appBar: AppBar(title: Text('Multi Split View Example')),
        body: Column(children: [buttons, Expanded(child: theme)])
        // body: horizontal,
        );
  }

  _onWeightChange() {
    print('weight change');
  }

  _onRemoveButtonClick() {
    if (_boxes.isNotEmpty) {
      _removeBox(_boxes.first);
    }
  }

  _onSetWeightButtonClick() {
    if (_controller.areas.length >= 2) {
      _controller.areas = [Area(), Area(weight: .1)];
    }
  }

  _onAddButtonClick() {
    setState(() => _boxes.insert(0, _createBox()));
  }

  RandomColorBox _createBox() {
    return RandomColorBox(
      key: UniqueKey(),
      onRemove: _removeBox,
    );
  }

  void _removeBox(RandomColorBox box) {
    setState(() => _boxes.remove(box));
  }
}

class RandomColorBox extends StatefulWidget {
  const RandomColorBox({
    required this.onRemove,
    Key? key,
  }) : super(key: key);

  final void Function(RandomColorBox box) onRemove;

  @override
  State<RandomColorBox> createState() => _RandomColorBoxState();
}

class _RandomColorBoxState extends State<RandomColorBox> {
  late Color _color;

  @override
  void initState() {
    super.initState();
    _color = Colors.primaries[Random().nextInt(Colors.primaries.length)];
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => widget.onRemove(widget),
      child: ColoredBox(
        color: _color,
      ),
    );
  }
}
