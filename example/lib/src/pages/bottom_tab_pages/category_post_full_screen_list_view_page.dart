
import 'package:flutter/material.dart';
import 'package:hbase/hbase.dart';

import '../post/views/demo_post_full_screen_list_view.dart';


/// 用来构建首页的分类无限全屏 post 下拉列表页面
class CategoryPostFullScreenListViewPage extends StatelessWidget {
  final List<TabData> tabs;

  const CategoryPostFullScreenListViewPage({super.key, required this.tabs});

  @override
  Widget build(BuildContext context) {
    return TabBarViewAppBarTitlePage(
      isExtendBodyBehindAppBar: true,
      tabs: tabs,
      tabBarViewContentBuilder: (context, tab) {
        var chnCodes = ['hanbeauti'];
        var tagCodes = tab.id == 'rcmd' ? null : [tab.id];
        var postPager = ChannelTagPostPager(chnCodes: chnCodes, tagCodes: tagCodes, isReelOnly: true, pageSize: 12);
        return DemoPostFullScreenListView(postPager: postPager, distanceCountToPreLoad: postPager.pageSize - 6,);
      },
    );
  }

}