import 'package:multi_split_view/src/divider_painter.dart';
import 'package:multi_split_view/src/multi_split_view.dart';

/// The [MultiSplitView] theme.
/// Defines the configuration of the overall visual [MultiSplitViewTheme] for a widget subtree within the app.
class MultiSplitViewThemeData {
  static const double defaultDividerThickness = 10.0;
  static const double defaultDividerHandleBuffer = 0;

  /// Builds a theme data.
  /// The [dividerThickness] argument must also be positive.
  MultiSplitViewThemeData(
      {this.dividerThickness = defaultDividerThickness,
      this.dividerPainter,
      this.dividerHandleBuffer = defaultDividerHandleBuffer}) {
    if (dividerThickness < 0) {
      throw ArgumentError('The value cannot be negative: $dividerThickness.',
          'dividerThickness');
    }
    if (dividerHandleBuffer < 0) {
      throw ArgumentError('The value cannot be negative: $dividerHandleBuffer.',
          'dividerHandleBuffer');
    }
  }

  final double dividerThickness;

  /// Defines the additional clickable area around the divider.
  final double dividerHandleBuffer;

  /// Defines a divider painter. The default value is [NULL].
  final DividerPainter? dividerPainter;
}
