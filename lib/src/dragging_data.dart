class DraggingData {
  factory DraggingData(
      {required int dividerIndex,
      required double initialDragPos,
      required List<double> weights,
      required double size,
      required double dividerThickness}) {
    final int childrenCount = weights.length;
    final double totalDividerSize = (childrenCount - 1) * dividerThickness;
    final double availableSize = size - totalDividerSize;
    List<double> childrenSize = [];
    for (double weight in weights) {
      childrenSize.add(weight * availableSize);
    }
    double initialChild1Size = childrenSize[dividerIndex];
    double initialChild2Size = childrenSize[dividerIndex + 1];
    return DraggingData._(
        dividerIndex: dividerIndex,
        childrenSize: childrenSize,
        initialChild1Size: initialChild1Size,
        initialChild2Size: initialChild2Size,
        initialDragPos: initialDragPos);
  }

  DraggingData._(
      {required this.dividerIndex,
      required this.childrenSize,
      required this.initialChild1Size,
      required this.initialChild2Size,
      required this.initialDragPos});

  final int dividerIndex;
  List<double> childrenSize;
  double initialDragPos;
  double initialChild1Size;
  double initialChild2Size;
}
