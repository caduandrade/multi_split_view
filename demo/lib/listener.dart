import 'package:flutter/widgets.dart';
import 'package:multi_split_view/multi_split_view.dart';
import 'package:multi_split_view_demo/example_widget.dart';

class SizeListenerExample extends ExampleWidget {
  @override
  Widget build(BuildContext context) {
    Widget child1 = buildContent(1);
    Widget child2 = buildContent(2);
    Widget child3 = buildContent(3);
    Widget child4 = buildContent(4);

    MultiSplitView multiSplitView = MultiSplitView(
        children: [child1, child2, child3, child4],
        onSizeChange: (childIndex1, childIndex2) => demoConsole(context,
            'Index of children whose size has changed: $childIndex1 and $childIndex2'));

    return multiSplitView;
  }
}
