import 'package:meta/meta.dart';

@internal
class InitialDrag {
  InitialDrag(
      {required this.initialDragPos,
      required this.initialChild1Size,
      required this.initialChild2Size,
      required this.minimalChild1Size,
      required this.minimalChild2Size,
      required this.sumMinimals,
      required this.sumSizes,
      required this.child1Start,
      required this.child2End,
      required this.posLimitStart,
      required this.posLimitEnd});

  final double initialDragPos;
  final double initialChild1Size;
  final double initialChild2Size;
  final double minimalChild1Size;
  final double minimalChild2Size;
  final double sumMinimals;
  final double sumSizes;
  final double child1Start;
  final double child2End;
  final double posLimitStart;
  final double posLimitEnd;
  bool posBeforeMinimalChild1 = false;
  bool posAfterMinimalChild2 = false;
}
