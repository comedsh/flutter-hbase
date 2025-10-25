// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:hbase/hbase.dart';
import 'package:sycomponents/components.dart';

/// 应用自定义自己的 hotspot 页面
class HotspotView extends StatelessWidget {
  final List<String> chnCodes;
  /// 作为 [HotspotProfileCardSwiperView] 组件的核心构造参数，如果该数组为空，则该组件将会展示空
  final List<ChannelTag> tags;

  const HotspotView({super.key, required this.chnCodes, required this.tags});

  @override
  Widget build(BuildContext context) {
    return NestedScrollView(
      headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
        return [
          SliverToBoxAdapter(child: indicator(iconData: FeatherIcons.chevronsRight, title: '热门帖文')),
          SliverToBoxAdapter(child: HotspotPostCardSwiperView(chnCodes: chnCodes,)),
          SliverToBoxAdapter(child: indicator(iconData: FeatherIcons.chevronsRight, title: '分类热榜')),
          SliverToBoxAdapter(child: HotspotProfileCardSwiperView(chnCodes: chnCodes, tags: tags,)),
          SliverAppBar(
            automaticallyImplyLeading: false, 
            title: indicator(iconData: FeatherIcons.chevronsRight, title: '推荐'), 
            pinned: true, 
            titleSpacing: 0, // title 左边的 spacing 置为 0
            forceElevated: innerBoxIsScrolled,
            backgroundColor: Theme.of(context).cardColor,
          ),
        ];
      },
        body: DefaultTabController(
          length: 1,
          child: ProfileListView(pager: HotestProfilePager(chnCodes: chnCodes)),
        ),

    );
  }

  indicator({
    required IconData iconData,
    required String title,
    double iconSize=18.0, 
    double fontSize=15.0
  }) => Padding(
    padding: EdgeInsets.symmetric(horizontal: sp(14), vertical: sp(10)),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(iconData, size: sp(iconSize),),
        SizedBox(width: sp(4)),
        Text(title, style: TextStyle(fontWeight: FontWeight.w600, fontSize: sp(fontSize)))
      ]
    ),
  );

}