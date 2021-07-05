import 'package:demoflu/demoflu.dart';
import 'package:flutter/material.dart';
import 'package:multi_split_view_demo/divider_color.dart';
import 'package:multi_split_view_demo/divider_painter.dart';
import 'package:multi_split_view_demo/divider_thickness.dart';
import 'package:multi_split_view_demo/add_remove.dart';
import 'package:multi_split_view_demo/horizontal.dart';
import 'package:multi_split_view_demo/horizontal_vertical.dart';
import 'package:multi_split_view_demo/listener.dart';
import 'package:multi_split_view_demo/minimal_size.dart';
import 'package:multi_split_view_demo/minimal_weight.dart';
import 'package:multi_split_view_demo/resizable.dart';
import 'package:multi_split_view_demo/setting_weight.dart';
import 'package:multi_split_view_demo/vertical.dart';

void main() {
  Size? maxSize;
  // maxSize = Size(400, 300);
  runApp(DemoFluApp(
      title: 'Multi split view (1.4.0)',
      widgetBackground: Colors.white,
      sections: [
        Section(examples: [
          Example(
              name: 'Horizontal',
              builder: (buttonClickNotifier) => HorizontalExample(),
              codeFile: 'lib/horizontal.dart',
              maxSize: maxSize),
          Example(
              name: 'Vertical',
              builder: (buttonClickNotifier) => VerticalExample(),
              codeFile: 'lib/vertical.dart',
              maxSize: maxSize),
          Example(
              name: 'Horizontal and vertical',
              builder: (buttonClickNotifier) => HorizontalVerticalExample(),
              codeFile: 'lib/horizontal_vertical.dart',
              maxSize: maxSize)
        ]),
        Section(name: 'Size', examples: [
          Example(
              name: 'Setting the weight',
              builder: (buttonClickNotifier) => SettingWeightExample(),
              codeFile: 'lib/setting_weight.dart',
              maxSize: maxSize),
          Example(
              name: 'Minimal weight',
              builder: (buttonClickNotifier) => MinimalWeightExample(),
              codeFile: 'lib/minimal_weight.dart',
              maxSize: maxSize),
          Example(
              name: 'Minimal size',
              builder: (buttonClickNotifier) => MinimalSizeExample(),
              codeFile: 'lib/minimal_size.dart',
              maxSize: maxSize),
          Example(
              name: 'Resizing disabled',
              builder: (buttonClickNotifier) => ResizableExample(),
              codeFile: 'lib/resizable.dart',
              maxSize: maxSize),
          Example(
              name: 'Listener',
              builder: (buttonClickNotifier) => SizeListenerExample(),
              codeFile: 'lib/listener.dart',
              consoleEnabled: true,
              maxSize: maxSize)
        ]),
        Section(name: 'Divider', examples: [
          Example(
              name: 'Color',
              builder: (buttonClickNotifier) => DividerColorExample(),
              codeFile: 'lib/divider_color.dart',
              maxSize: maxSize),
          Example(
              name: 'Thickness',
              builder: (buttonClickNotifier) => DividerThicknessExample(),
              codeFile: 'lib/divider_thickness.dart',
              maxSize: maxSize),
          Example(
              name: 'Painter',
              builder: (buttonClickNotifier) => DividerPainterExample(),
              codeFile: 'lib/divider_painter.dart',
              maxSize: maxSize)
        ]),
        Section(name: 'Dynamic', examples: [
          Example(
              name: 'Add/Remove',
              builder: (buttonClickNotifier) =>
                  AddRemoveExample(buttonClickNotifier),
              codeFile: 'lib/add_remove.dart',
              maxSize: maxSize,
              buttons: ['Add', 'Remove'])
        ])
      ]));
}
