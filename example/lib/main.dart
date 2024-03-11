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
  static const int _initial = 3;

  late final List<RandomColorBox> _boxes;

  final MultiSplitViewController _controller =
      MultiSplitViewController(areas: [Area(size: 100)]);

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
        child: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 10,
            runSpacing: 10,
            children: [
              ElevatedButton(
                  onPressed: _onAddFlexButtonClick,
                  child: const Text('Add flex')),
              ElevatedButton(
                  onPressed: _onAddSizeButtonClick,
                  child: const Text('Add size')),
              ElevatedButton(
                  onPressed:
                      _boxes.isNotEmpty ? _onRemoveFirstButtonClick : null,
                  child: const Text('Remove first')),
              ElevatedButton(
                  onPressed:
                      _boxes.isNotEmpty ? _onSetFirstFlexButtonClick : null,
                  child: const Text('Change first area flex'))
            ]));

    Widget? content;
    if (_boxes.isNotEmpty) {
      MultiSplitView multiSplitView = MultiSplitView(
          onWeightChange: _onWeightChange,
          onDividerTap: _onDividerTap,
          onDividerDoubleTap: _onDividerDoubleTap,
          controller: _controller,
          children: _boxes);

      content = MultiSplitViewTheme(
          data: MultiSplitViewThemeData(
              dividerPainter: DividerPainters.grooved2()),
          child: multiSplitView);
    } else {
      content = const Center(child: Text('Empty'));
    }

    return Scaffold(
        appBar: AppBar(title: const Text('Multi Split View Example')),
        body: Column(children: [buttons, Expanded(child: content)])
        // body: horizontal,
        );
  }

  _onWeightChange() {
    if (kDebugMode) {
      // print('weight change');
    }
  }

  _onRemoveFirstButtonClick() {
    if (_boxes.isNotEmpty) {
      _removeBox(_boxes.first);
    }
  }

  _onSetFirstFlexButtonClick() {
    if (_controller.areas.isNotEmpty) {
      List<Area> list = List.from(_controller.areas);
      list[0] = Area(flex: 3);
      _controller.areas = list;
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

  _onAddFlexButtonClick() {
    _add(Area());
  }

  _onAddSizeButtonClick() {
    _add(Area(size: 100));
  }

  _add(Area area) {
    _boxes.add(_createBox());
    List<Area> list = List.from(_controller.areas);
    list.add(area);
    _controller.areas = list;
    setState(() {
      // update empty text and buttons
    });
  }

  RandomColorBox _createBox() {
    return RandomColorBox(
      key: UniqueKey(),
      onRemove: _removeBox,
    );
  }

  void _removeBox(RandomColorBox box) {
    int index = _boxes.indexOf(box);
    List<Area> list = List.from(_controller.areas);
    list.removeAt(index);
    _boxes.removeAt(index);
    _controller.areas = list;
    setState(() {
      // update empty text and buttons
    });
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
      child: Container(color: _color, child: const Placeholder()),
    );
  }
}
