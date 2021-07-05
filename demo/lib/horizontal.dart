import 'package:flutter/widgets.dart';
import 'package:multi_split_view/multi_split_view.dart';
import 'package:multi_split_view_demo/example_widget.dart';

class HorizontalExample extends StatelessWidget with ContentBuilder {
  @override
  Widget build(BuildContext context) {
    Widget child1 = buildContent(1);
    Widget child2 = buildContent(2);
    Widget child3 = buildContent(3);

    MultiSplitView multiSplitView =
        MultiSplitView(children: [child1, child2, child3]);

    return multiSplitView;
  }
}
