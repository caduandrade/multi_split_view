import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:multi_split_view/src/area.dart';
import 'package:multi_split_view/src/area_widget_builder.dart';
import 'package:multi_split_view/src/controller.dart';
import 'package:multi_split_view/src/divider_tap_typedefs.dart';
import 'package:multi_split_view/src/divider_widget.dart';
import 'package:multi_split_view/src/internal/divider_util.dart';
import 'package:multi_split_view/src/internal/layout_constraints.dart';
import 'package:multi_split_view/src/internal/layout_delegate.dart';
import 'package:multi_split_view/src/policies.dart';
import 'package:multi_split_view/src/theme_data.dart';
import 'package:multi_split_view/src/theme_widget.dart';

/// A widget to provides horizontal or vertical multiple split view.
class MultiSplitView extends StatefulWidget {
  static const Axis defaultAxis = Axis.horizontal;

  /// Creates an [MultiSplitView].
  ///
  /// The default value for [axis] argument is [Axis.horizontal].
  /// The [children] argument is required.
  const MultiSplitView(
      {Key? key,
      this.axis = MultiSplitView.defaultAxis,
      this.controller,
      this.dividerBuilder,
      this.onDividerDragStart,
      this.onDividerDragUpdate,
      this.onDividerDragEnd,
      this.onDividerTap,
      this.onDividerDoubleTap,
      this.resizable = true,
      this.antiAliasingWorkaround = false,
      this.pushDividers = false,
      this.initialAreas,
      this.sizeOverflowPolicy = SizeOverflowPolicy.shrinkLast,
      this.sizeUnderflowPolicy = SizeUnderflowPolicy.stretchLast,
      this.minSizeRecoveryPolicy = MinSizeRecoveryPolicy.firstToLast,
      this.fallbackWidth = 500,
      this.fallbackHeight = 500,
      this.builder,
      this.areaClipBehavior = Clip.hardEdge})
      : super(key: key);

  final Axis axis;
  final MultiSplitViewController? controller;
  final List<Area>? initialAreas;

  /// The area widget builder.
  final AreaWidgetBuilder? builder;

  /// Indicates whether a divider can push others.
  final bool pushDividers;

  /// Signature for when a divider tap has occurred.
  final DividerTapCallback? onDividerTap;

  /// Signature for when a divider double tap has occurred.
  final DividerTapCallback? onDividerDoubleTap;

  /// Defines a builder of dividers. Overrides the default divider
  /// created by the theme.
  final DividerBuilder? dividerBuilder;

  /// Indicates whether it is resizable. The default value is [TRUE].
  final bool resizable;

  /// Function to listen to divider dragging start.
  final OnDividerDragEvent? onDividerDragStart;

  /// Function to listen to divider dragging update.
  final OnDividerDragEvent? onDividerDragUpdate;

  /// Function to listen to divider dragging end.
  final OnDividerDragEvent? onDividerDragEnd;

  /// Represents the policy for handling overflow of non-flexible areas within
  /// a container.
  final SizeOverflowPolicy sizeOverflowPolicy;

  /// Represents the policy for handling cases where the total size of
  /// non-flexible areas within a container is smaller than the available space.
  final SizeUnderflowPolicy sizeUnderflowPolicy;

  /// /// Represents the order in which the minimum size of the areas is recovered.
  final MinSizeRecoveryPolicy minSizeRecoveryPolicy;

  /// Enables a workaround for https://github.com/flutter/flutter/issues/14288
  /// The workaround to minimize the problem is to round the coordinates to
  /// integer values. As a side effect, some areas may stretch or shrink
  /// slightly as the divider is dragged.
  final bool antiAliasingWorkaround;

  /// The width to use when it is in a situation with an unbounded width.
  ///
  /// See also:
  ///
  ///  * [fallbackHeight], the same but vertically.
  final double fallbackWidth;

  /// The height to use when it is in a situation with an unbounded height.
  ///
  /// See also:
  ///
  ///  * [fallbackWidth], the same but horizontally.
  final double fallbackHeight;

  /// Controls how to clip each area.
  ///
  /// Defaults to [Clip.hardEdge].
  final Clip areaClipBehavior;

  @override
  State createState() => _MultiSplitViewState();
}

/// State for [MultiSplitView]
class _MultiSplitViewState extends State<MultiSplitView> {
  late MultiSplitViewController _controller;

  _DraggingDivider? _draggingDivider;

  ValueNotifier<int?> _hoverDividerIndex = ValueNotifier<int?>(null);

  Object? _lastAreasHash;

  LayoutConstraints? _layoutConstraints;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller != null
        ? widget.controller!
        : MultiSplitViewController(areas: widget.initialAreas);
    _stateHashCodeValidation();
    ControllerHelper.setStateHashCode(_controller, hashCode);
    _controller.addListener(_rebuild);
  }

  @override
  void dispose() {
    _controller.removeListener(_rebuild);
    super.dispose();
  }

  void _rebuild() {
    setState(() {});
  }

  @override
  void deactivate() {
    ControllerHelper.setStateHashCode(_controller, null);
    super.deactivate();
  }

  @override
  void didUpdateWidget(MultiSplitView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != _controller) {
      List<Area> areas = _controller.areas;
      ControllerHelper.setStateHashCode(_controller, null);
      _controller.removeListener(_rebuild);

      _controller = widget.controller != null
          ? widget.controller!
          : MultiSplitViewController(areas: areas);
      _stateHashCodeValidation();
      ControllerHelper.setStateHashCode(_controller, hashCode);
      _controller.addListener(_rebuild);
    }
  }

  /// Checks a controller's [_stateHashCode] to identify if it is
  /// not being shared by another instance of [MultiSplitView].
  void _stateHashCodeValidation() {
    if (ControllerHelper.getStateHashCode(_controller) != null &&
        ControllerHelper.getStateHashCode(_controller) != hashCode) {
      throw StateError(
          'It is not allowed to share MultiSplitViewController between MultiSplitView instances.');
    }
  }

  @override
  Widget build(BuildContext context) {
    MultiSplitViewThemeData themeData = MultiSplitViewTheme.of(context);

    return LayoutBuilder(builder: (context, constraints) {
      ControllerHelper controllerHelper = ControllerHelper(_controller);

      final double containerSize = widget.axis == Axis.horizontal
          ? constraints.maxWidth
          : constraints.maxHeight;

      if (_lastAreasHash != controllerHelper.areasHash ||
          _layoutConstraints == null ||
          _layoutConstraints!.containerSize != containerSize ||
          _layoutConstraints!.dividerThickness != themeData.dividerThickness) {
        _layoutConstraints = LayoutConstraints(
            controller: _controller,
            containerSize: containerSize,
            dividerThickness: themeData.dividerThickness,
            dividerHandleBuffer: themeData.dividerHandleBuffer);
        _layoutConstraints!.adjustAreas(
            controllerHelper: controllerHelper,
            sizeOverflowPolicy: widget.sizeOverflowPolicy,
            sizeUnderflowPolicy: widget.sizeUnderflowPolicy,
            minSizeRecoveryPolicy: widget.minSizeRecoveryPolicy);
        _lastAreasHash = controllerHelper.areasHash;
      }

      List<Widget> children = [];

      for (int index = 0; index < _controller.areasCount; index++) {
        Area area = _controller.getArea(index);

        // area widget
        Widget child;
        if (area.builder != null) {
          child = area.builder!(context, area);
        } else if (widget.builder != null) {
          child = widget.builder!(context, area);
        } else {
          child = Container();
        }

        child = IgnorePointer(child: child, ignoring: _draggingDivider != null);

        MouseCursor cursor = MouseCursor.defer;
        if (_draggingDivider != null) {
          cursor = widget.axis == Axis.horizontal
              ? SystemMouseCursors.resizeColumn
              : SystemMouseCursors.resizeRow;
        }
        child = MouseRegion(
            cursor: cursor,
            child: child,
            opaque: _draggingDivider != null,
            hitTestBehavior: _draggingDivider != null
                ? HitTestBehavior.opaque
                : HitTestBehavior.translucent);
        children.insert(
            0,
            LayoutId(
                key: ValueKey(area.id),
                id: index,
                child: ClipRect(
                    clipBehavior: widget.areaClipBehavior, child: child)));

        // divisor widget
        // added last to ensure they are painted over ensuring the handle
        // buffer is not below the area.
        if (index < _controller.areasCount - 1) {
          children.add(LayoutId(
              id: 'd$index',
              child: ValueListenableBuilder(
                  valueListenable: _hoverDividerIndex,
                  builder: (context, indexHover, child) {
                    bool highlighted = (_draggingDivider?.index == index ||
                        (_draggingDivider == null &&
                            _hoverDividerIndex.value == index));
                    Widget dividerWidget = widget.dividerBuilder != null
                        ? widget.dividerBuilder!(
                            widget.axis == Axis.horizontal
                                ? Axis.vertical
                                : Axis.horizontal,
                            index,
                            widget.resizable,
                            _draggingDivider?.index == index,
                            highlighted,
                            themeData)
                        : DividerWidget(
                            axis: widget.axis == Axis.horizontal
                                ? Axis.vertical
                                : Axis.horizontal,
                            index: index,
                            themeData: themeData,
                            highlighted: highlighted,
                            resizable: widget.resizable,
                            dragging: _draggingDivider?.index == index);
                    if (widget.resizable) {
                      if (themeData.dividerHandleBuffer > 0) {
                        // handle buffer around the divider
                        double lr = widget.axis == Axis.vertical
                            ? 0
                            : themeData.dividerHandleBuffer;
                        double tb = widget.axis == Axis.horizontal
                            ? 0
                            : themeData.dividerHandleBuffer;
                        dividerWidget = Padding(
                            padding: EdgeInsets.fromLTRB(lr, tb, lr, tb),
                            child: dividerWidget);
                      }
                      dividerWidget = GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTap: widget.onDividerTap != null
                              ? () => widget.onDividerTap!(index)
                              : null,
                          onDoubleTap: widget.onDividerDoubleTap != null
                              ? () => widget.onDividerDoubleTap!(index)
                              : null,
                          onHorizontalDragDown: widget.axis == Axis.vertical
                              ? null
                              : (detail) => _onDragDown(detail, index),
                          onHorizontalDragStart: widget.axis == Axis.vertical
                              ? null
                              : (detail) => _onDragStart(index),
                          onHorizontalDragCancel: widget.axis == Axis.vertical
                              ? null
                              : () => _onDragCancel(),
                          onHorizontalDragEnd: widget.axis == Axis.vertical
                              ? null
                              : (detail) => _onDragEnd(index),
                          onHorizontalDragUpdate: widget.axis == Axis.vertical
                              ? null
                              : (detail) => _onDragUpdate(
                                  detail, index, controllerHelper),
                          onVerticalDragDown: widget.axis == Axis.horizontal
                              ? null
                              : (detail) => _onDragDown(detail, index),
                          onVerticalDragStart: widget.axis == Axis.horizontal
                              ? null
                              : (detail) => _onDragStart(index),
                          onVerticalDragCancel: widget.axis == Axis.horizontal
                              ? null
                              : () => _onDragCancel(),
                          onVerticalDragEnd: widget.axis == Axis.horizontal
                              ? null
                              : (detail) => _onDragEnd(index),
                          onVerticalDragUpdate: widget.axis == Axis.horizontal
                              ? null
                              : (detail) => _onDragUpdate(
                                  detail, index, controllerHelper),
                          child: dividerWidget);
                      dividerWidget = _mouseRegion(
                          index: index,
                          axis: widget.axis == Axis.horizontal
                              ? Axis.vertical
                              : Axis.horizontal,
                          dividerWidget: dividerWidget,
                          themeData: themeData);
                    }
                    return dividerWidget;
                  })));
        }
      }
      return LimitedBox(
          maxWidth: widget.fallbackWidth,
          maxHeight: widget.fallbackHeight,
          child: CustomMultiChildLayout(
              children: children,
              delegate: LayoutDelegate(
                  controller: _controller,
                  axis: widget.axis,
                  layoutConstraints: _layoutConstraints!,
                  antiAliasingWorkaround: widget.antiAliasingWorkaround)));
    });
  }

  /// Updates the hover divider index.
  void _updatesHoverDividerIndex(
      {int? index, required MultiSplitViewThemeData themeData}) {
    if (_hoverDividerIndex.value != index &&
        (themeData.dividerPainter != null || widget.dividerBuilder != null)) {
      _hoverDividerIndex.value = index;
    }
  }

  void _onDragDown(DragDownDetails detail, int index) {
    setState(() {
      _draggingDivider = _DraggingDivider(
          index: index,
          initialInnerPos: widget.axis == Axis.horizontal
              ? detail.localPosition.dx
              : detail.localPosition.dy);
    });
  }

  void _onDragUpdate(
      DragUpdateDetails detail, int index, ControllerHelper controllerHelper) {
    if (_draggingDivider == null) {
      return;
    }
    final Offset offset = _offset(context, detail.globalPosition);
    final double position;
    if (widget.axis == Axis.horizontal) {
      if (detail.delta.dx == 0) {
        return;
      }
      position = offset.dx;
    } else {
      if (detail.delta.dy == 0) {
        return;
      }
      position = offset.dy;
    }

    final double newDividerStart = position - _draggingDivider!.initialInnerPos;
    final double lastDividerStart = _layoutConstraints!.dividerStartOf(
        index: index,
        controller: _controller,
        antiAliasingWorkaround: widget.antiAliasingWorkaround);

    DividerUtil.move(
        controller: _controller,
        layoutConstraints: _layoutConstraints!,
        dividerIndex: index,
        pixels: newDividerStart - lastDividerStart,
        pushDividers: widget.pushDividers);

    controllerHelper.notifyListeners();
    if (widget.onDividerDragUpdate != null) {
      Future.delayed(Duration.zero, () => widget.onDividerDragUpdate!(index));
    }
  }

  void _onDragCancel() {
    if (_draggingDivider == null) {
      return;
    }
    setState(() {
      _draggingDivider = null;
    });
  }

  void _onDragStart(int index) {
    if (_draggingDivider == null) {
      return;
    }
    if (widget.onDividerDragStart != null) {
      Future.delayed(Duration.zero, () => widget.onDividerDragStart!(index));
    }
  }

  void _onDragEnd(int index) {
    if (_draggingDivider == null) {
      return;
    }
    setState(() {
      _draggingDivider = null;
    });
    if (widget.onDividerDragEnd != null) {
      Future.delayed(Duration.zero, () => widget.onDividerDragEnd!(index));
    }
  }

  /// Wraps the divider widget with a [MouseRegion].
  Widget _mouseRegion(
      {required int index,
      required Axis axis,
      required Widget dividerWidget,
      required MultiSplitViewThemeData themeData}) {
    MouseCursor cursor = axis == Axis.horizontal
        ? SystemMouseCursors.resizeRow
        : SystemMouseCursors.resizeColumn;
    return MouseRegion(
        cursor: cursor,
        onEnter: (event) =>
            _updatesHoverDividerIndex(index: index, themeData: themeData),
        onExit: (event) => _updatesHoverDividerIndex(themeData: themeData),
        child: dividerWidget);
  }

  /// Builds an [Offset] for cursor position.
  Offset _offset(BuildContext context, Offset globalPosition) {
    final RenderBox container = context.findRenderObject() as RenderBox;
    return container.globalToLocal(globalPosition);
  }
}

class _DraggingDivider {
  _DraggingDivider({required this.index, required this.initialInnerPos});

  final int index;
  final double initialInnerPos;
}

typedef DividerBuilder = Widget Function(Axis axis, int index, bool resizable,
    bool dragging, bool highlighted, MultiSplitViewThemeData themeData);

typedef OnDividerDragEvent = void Function(int index);
