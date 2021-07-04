import 'package:demoflu/demoflu.dart';
import 'package:flutter/material.dart';
import 'package:multi_split_view_demo/divider_color.dart';
import 'package:multi_split_view_demo/divider_painter.dart';
import 'package:multi_split_view_demo/divider_thickness.dart';
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
        DFSection(examples: [
          DFExample(
              name: 'Horizontal',
              builder: (context) => HorizontalExample(),
              codeFile: 'lib/horizontal.dart',
              maxSize: maxSize),
          DFExample(
              name: 'Vertical',
              builder: (context) => VerticalExample(),
              codeFile: 'lib/vertical.dart',
              maxSize: maxSize),
          DFExample(
              name: 'Horizontal and vertical',
              builder: (context) => HorizontalVerticalExample(),
              codeFile: 'lib/horizontal_vertical.dart',
              maxSize: maxSize)
        ]),
        DFSection(name: 'Size', examples: [
          DFExample(
              name: 'Setting the weight',
              builder: (context) => SettingWeightExample(),
              codeFile: 'lib/setting_weight.dart',
              maxSize: maxSize),
          DFExample(
              name: 'Minimal weight',
              builder: (context) => MinimalWeightExample(),
              codeFile: 'lib/minimal_weight.dart',
              maxSize: maxSize),
          DFExample(
              name: 'Minimal size',
              builder: (context) => MinimalSizeExample(),
              codeFile: 'lib/minimal_size.dart',
              maxSize: maxSize),
          DFExample(
              name: 'Resizing disabled',
              builder: (context) => ResizableExample(),
              codeFile: 'lib/resizable.dart',
              maxSize: maxSize),
          DFExample(
              name: 'Listener',
              builder: (context) => SizeListenerExample(),
              codeFile: 'lib/listener.dart',
              consoleEnabled: true,
              maxSize: maxSize)
        ]),
        DFSection(name: 'Divider', examples: [
          DFExample(
              name: 'Color',
              builder: (context) => DividerColorExample(),
              codeFile: 'lib/divider_color.dart',
              maxSize: maxSize),
          DFExample(
              name: 'Thickness',
              builder: (context) => DividerThicknessExample(),
              codeFile: 'lib/divider_thickness.dart',
              maxSize: maxSize),
          DFExample(
              name: 'Painter',
              builder: (context) => DividerPainterExample(),
              codeFile: 'lib/divider_painter.dart',
              maxSize: maxSize)
        ])
      ]));
}
