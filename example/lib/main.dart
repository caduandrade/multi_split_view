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
  final List<Color> _colors = [];

  final MultiSplitViewController _controller =
      MultiSplitViewController(areas: [Area(size: 100)]);

  @override
  void initState() {
    super.initState();
    _colors.addAll(List.generate(3, (_) => _randomColor()));
    _controller.addListener(_rebuild);
  }

  @override
  void dispose() {
    super.dispose();
    _controller.removeListener(_rebuild);
  }

  void _rebuild() {
    setState(() {
      // rebuild to update empty text and buttons
    });
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
                      _colors.isNotEmpty ? _onRemoveFirstButtonClick : null,
                  child: const Text('Remove first')),
              ElevatedButton(
                  onPressed:
                      _colors.isNotEmpty ? _onSetFirstFlexButtonClick : null,
                  child: const Text('Change first area flex'))
            ]));

    Widget? content;
    if (_colors.isNotEmpty) {
      MultiSplitView multiSplitView = MultiSplitView.builder(
          onWeightChange: _onWeightChange,
          onDividerTap: _onDividerTap,
          onDividerDoubleTap: _onDividerDoubleTap,
          controller: _controller,
          count: _colors.length,
          widgetBuilder: (context, index, area) => ColorWidget(
              index: index,
              area: area,
              color: _colors[index],
              controller: _controller,
              onRemove: _removeColor));

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

  Color _randomColor() {
    Random random = Random();
    return Color.fromARGB(
        255, random.nextInt(200), random.nextInt(200), random.nextInt(200));
  }

  _onWeightChange() {
    if (kDebugMode) {
      // print('weight change');
    }
  }

  _onRemoveFirstButtonClick() {
    if (_colors.isNotEmpty) {
      _removeColor(0);
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
    _colors.add(_randomColor());
    List<Area> areas = List.from(_controller.areas);
    areas.add(area);
    _controller.areas = areas;
  }

  void _removeColor(int index) {
    _colors.removeAt(index);
    List<Area> areas = List.from(_controller.areas);
    areas.removeAt(index);
    _controller.areas = areas;
  }
}

class ColorWidget extends StatelessWidget {
  const ColorWidget(
      {Key? key,
      required this.color,
      required this.index,
      required this.onRemove,
      required this.area,
      required this.controller})
      : super(key: key);

  final Color color;
  final int index;
  final Area area;
  final void Function(int index) onRemove;
  final MultiSplitViewController controller;

  @override
  Widget build(BuildContext context) {
    Widget info = ListenableBuilder(
        listenable: controller,
        builder: (BuildContext context, Widget? child) {
          List<Widget> children = [];
          TextStyle textStyle = const TextStyle(fontSize: 10);
          if (area.size != null) {
            children.add(Text('size: ${area.size!}', style: textStyle));
          }
          if (area.flex != null) {
            children.add(Text('flex: ${area.flex!}', style: textStyle));
          }
          return Center(
              child: Container(
                  color: const Color.fromARGB(200, 255, 255, 255),
                  padding: const EdgeInsets.fromLTRB(3, 2, 3, 2),
                  child: Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: children)));
        });

    return InkWell(
        onTap: () => onRemove(index),
        child: Container(
            color: color,
            child: Stack(children: [
              Placeholder(
                color: invert(color),
              ),
              info
            ])));
  }

  Color invert(Color color) {
    final r = 255 - color.red;
    final g = 255 - color.green;
    final b = 255 - color.blue;

    return Color.fromARGB(255, r, g, b);
  }
}
