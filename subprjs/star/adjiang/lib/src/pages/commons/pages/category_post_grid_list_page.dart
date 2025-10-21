
import 'package:flutter/material.dart';
import 'package:hbase/hbase.dart';

import '../views/post_grid_list_view.dart';

class CategoryPostGridListPage extends StatelessWidget {
  final List<String> chnCodes;
  final List<TabData> tabs;
  /// 因为分页器 [ChannelTagPostPager] 目前会被多个页面共用，我想知道是哪个具体页面使用的，供后台子应用可以单独定制；
  final PageLabel pageLabel;

  const CategoryPostGridListPage({
    super.key, 
    required this.chnCodes,
    required this.tabs,
    required this.pageLabel
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
          isReelOnly: false,
          pageSize: 12,
          pageLabel: pageLabel
        );
        return PostGridListView(
          postPager: postPager, 
        );
      },
    );
  }

}