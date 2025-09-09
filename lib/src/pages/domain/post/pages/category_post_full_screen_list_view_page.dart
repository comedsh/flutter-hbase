
import 'package:flutter/material.dart';
import 'package:hbase/hbase.dart';

/// 用来构建首页的分类无限全屏 post 下拉列表页面
class CategoryPostFullScreenListViewPage extends StatelessWidget {
  final List<String> chnCodes;
  final List<TabData> tabs;
  final bool isReelOnly;

  const CategoryPostFullScreenListViewPage({
    super.key, 
    required this.chnCodes,
    required this.tabs,
    this.isReelOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return TabBarViewAppBarTitlePage(
      isExtendBodyBehindAppBar: true,
      tabs: tabs,
      tabBarViewContentBuilder: (context, tab) {
        var tagCodes = tab.id == 'rcmd' ? null : [tab.id];
        var postPager = ChannelTagPostPager(
          chnCodes: chnCodes, 
          tagCodes: tagCodes, 
          isReelOnly: isReelOnly, 
          pageSize: 12
        );
        return PostFullScreenListView(
          postPager: postPager, 
          distanceCountToPreLoad: postPager.pageSize - 6,
        );
      },
    );
  }

}