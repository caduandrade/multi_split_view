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
  final MultiSplitViewController _controller = MultiSplitViewController();

  bool _pushDividers = false;

  @override
  void initState() {
    super.initState();
    _controller.areas = [
      Area(data: _randomColor(), size: 600, min: 100),
      Area(data: _randomColor(), flex: 1),
      Area(data: _randomColor(), size: 150, min: 100),
      Area(data: _randomColor(), size: 150, min: 100),
    ];
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
                  onPressed: _controller.areasCount != 0
                      ? _onRemoveFirstButtonClick
                      : null,
                  child: const Text('Remove first')),
              Checkbox(
                  value: _pushDividers,
                  onChanged: (newValue) => setState(() {
                        _pushDividers = newValue!;
                      })),
              const Text("Push dividers")
            ]));

    Widget? content;
    if (_controller.areasCount != 0) {
      MultiSplitView multiSplitView = MultiSplitView(
          onDividerDragUpdate: _onDividerDragUpdate,
          onDividerTap: _onDividerTap,
          onDividerDoubleTap: _onDividerDoubleTap,
          controller: _controller,
          pushDividers: _pushDividers,
          builder: (BuildContext context, Area area) => ColorWidget(
              area: area, color: area.data, onRemove: _removeColor));

      content = Padding(
          padding: const EdgeInsets.all(16),
          child: MultiSplitViewTheme(
              data: MultiSplitViewThemeData(
                  dividerPainter: DividerPainters.grooved2()),
              child: multiSplitView));
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
    return Color.fromARGB(255, 155 + random.nextInt(100),
        155 + random.nextInt(100), 155 + random.nextInt(100));
  }

  _onDividerDragUpdate(int index) {
    if (kDebugMode) {
      // print('drag update: $index');
    }
  }

  _onRemoveFirstButtonClick() {
    if (_controller.areasCount != 0) {
      _controller.removeAreaAt(0);
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
    _controller.addArea(Area(data: _randomColor()));
  }

  _onAddSizeButtonClick() {
    _controller.addArea(Area(data: _randomColor(), size: 100));
  }

  void _removeColor(int index) {
    _controller.removeAreaAt(index);
  }
}

class ColorWidget extends StatelessWidget {
  const ColorWidget(
      {Key? key,
      required this.color,
      required this.onRemove,
      required this.area})
      : super(key: key);

  final Color color;
  final Area area;
  final void Function(int index) onRemove;

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];
    TextStyle textStyle = const TextStyle(fontSize: 10);
    if (area.size != null) {
      children.add(Text('size: ${area.size!}', style: textStyle));
    }
    if (area.flex != null) {
      children.add(Text('flex: ${area.flex!}', style: textStyle));
    }
    if (area.min != null) {
      children.add(Text('min: ${area.min!}', style: textStyle));
    }
    if (area.max != null) {
      children.add(Text('max: ${area.max!}', style: textStyle));
    }
    Widget info = Center(
        child: Container(
            color: const Color.fromARGB(200, 255, 255, 255),
            padding: const EdgeInsets.fromLTRB(3, 2, 3, 2),
            child: Wrap(
                runSpacing: 5,
                spacing: 5,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: children)));

    return InkWell(
        onTap: () => onRemove(area.index),
        child: Container(
            color: color,
            child: Stack(
                children: [const Placeholder(color: Colors.black), info])));
  }
}
