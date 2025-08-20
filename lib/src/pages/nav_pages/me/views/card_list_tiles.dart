import 'package:flutter/material.dart';

class CardListTiles extends StatelessWidget {
  /// 为什么最终将类型改为了 Widget，在封装 [ClearCacheListTile] 的时候返回的是被 [VisibilityDetector] 
  /// 所包装后的 ListTile
  // final List<ListTile> listTiles;
  final List<Widget> listTiles;
  const CardListTiles({super.key, required this.listTiles});

  @override
  Widget build(BuildContext context) {
    return Card(
      // surfaceTintColor: SyColors.getSecondaryColor(context),
      elevation: 2,
      // 重要，去掉在白色背景下 Card 的阴影
      // shadowColor: Colors.transparent,
      child: ListView(
        // 重要属性，默认情况下，ListView 顶上会留白比较多的空间，去掉顶上留白空间
        // padding: EdgeInsets.zero,
        // 重要属性，让 ListViewItem 不能滚动
        physics: const NeverScrollableScrollPhysics(),
        // 关键属性，能够让这种 Scrolling Widget 使得让它们的 childs 能够刚好填充所需的空间，否则布局混乱
        // https://www.dhiwise.com/post/flutter-shrinkwrap-strategies-boosting-flutter-ui-performanc
        shrinkWrap: true,
        children: listTiles,
      ),
    );
  }
}