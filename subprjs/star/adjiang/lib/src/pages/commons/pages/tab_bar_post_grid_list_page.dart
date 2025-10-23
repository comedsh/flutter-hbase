
import 'package:adjiang/src/pages/commons/pages/tab_bar_view_page.dart';
import 'package:flutter/material.dart';
import 'package:hbase/hbase.dart';

import '../views/post_grid_list_view.dart';

class TabBarPostGridListPage extends StatelessWidget {
  final List<String> chnCodes;
  final List<TabData> tabs;
  /// 因为分页器 [ChannelTagPostPager] 目前会被多个页面共用，我想知道是哪个具体页面使用的，供后台子应用可以单独定制；
  final PageLabel pageLabel;

  const TabBarPostGridListPage({
    super.key, 
    required this.chnCodes,
    required this.tabs,
    required this.pageLabel
  });

  @override
  Widget build(BuildContext context) {
    return TabBarViewPage(
      isExtendBodyBehindAppBar: true,
      tabs: tabs,
      tabBarViewContentBuilder: (context, tab) {
        var tagCodes = tab.id == 'rcmd' ? null : [tab.id];
        var postPager = ChannelTagPostPager(
          chnCodes: chnCodes,
          tagCodes: tagCodes,
          isReelOnly: false,
          /// 特别特别注意，这个值务必设置得大一些，否则“分类页” [PostAlbumListPage] 页面可能无法填充满一页，因为都是共用一个 [ChannelTagPostPager]
          /// 即共享请求缓存；之前这里就是设定的 12 个，导致分类页只能填充 12 个导致无法分页了。
          pageSize: 24,
          pageLabel: pageLabel
        );
        return PostGridListView(
          postPager: postPager, 
          tab: tab,
        );
      },
    );
  }

}