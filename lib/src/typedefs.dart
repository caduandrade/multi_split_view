import 'package:flutter/widgets.dart';
import 'package:multi_split_view/src/area.dart';
import 'package:multi_split_view/src/theme_data.dart';

typedef DividerBuilder = Widget Function(Axis axis, int index, bool resizable,
    bool dragging, bool highlighted, MultiSplitViewThemeData themeData);

typedef AreaWidgetBuilder = Widget Function(
    BuildContext context, int index, Area area);

typedef OnDividerDragUpdate = void Function(int index);
