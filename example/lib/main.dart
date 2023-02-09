import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:multi_split_view/multi_split_view.dart';

void main() => runApp(const MultiSplitViewExampleApp());

class MultiSplitViewExampleApp extends StatelessWidget {
  const MultiSplitViewExampleApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MultiSplitViewExample(),
    );
  }
}

class MultiSplitViewExample extends StatefulWidget {
  const MultiSplitViewExample({Key? key}) : super(key: key);

  @override
  MultiSplitViewExampleState createState() => MultiSplitViewExampleState();
}

class MultiSplitViewExampleState extends State<MultiSplitViewExample> {
  static const int _max = 40;
  static const int _initial = 3;

  late final List<RandomColorBox> _boxes;

  final MultiSplitViewController _controller = MultiSplitViewController();

  @override
  void initState() {
    super.initState();
    _boxes = List.generate(_initial, (_) => _createBox());
  }

  @override
  Widget build(BuildContext context) {
    Widget buttons = Container(
        color: Colors.white,
        padding: const EdgeInsets.all(8),
        child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
          Text('Horizontal widgets: ${_boxes.length} / $_max'),
          const SizedBox(width: 16),
          ElevatedButton(
              onPressed: _onAddButtonClick, child: const Text('Add')),
          const SizedBox(width: 16),
          ElevatedButton(
              onPressed: _onRemoveButtonClick, child: const Text('Remove')),
          const SizedBox(width: 16),
          ElevatedButton(
              onPressed: _onSetWeightButtonClick,
              child: const Text('Change second area weight'))
        ]));

    final List<Widget> children = _boxes;

    MultiSplitView multiSplitView = MultiSplitView(
        onWeightChange: _onWeightChange,
        onDividerTap: _onDividerTap,
        onDividerDoubleTap: _onDividerDoubleTap,
        controller: _controller,
        children: children);

    MultiSplitViewTheme theme = MultiSplitViewTheme(
        data:
            MultiSplitViewThemeData(dividerPainter: DividerPainters.grooved2()),
        child: multiSplitView);

    return Scaffold(
        appBar: AppBar(title: const Text('Multi Split View Example')),
        body: Column(children: [buttons, Expanded(child: theme)])
        // body: horizontal,
        );
  }

  _onWeightChange() {
    if (kDebugMode) {
      print('weight change');
    }
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

  _onDividerTap(int dividerIndex) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      duration: const Duration(seconds: 1),
      content: Text("Tap on divider: $dividerIndex"),
    ));
  }

  _onDividerDoubleTap(int dividerIndex) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      duration: const Duration(seconds: 1),
      content: Text("Double tap on divider: $dividerIndex"),
    ));
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
