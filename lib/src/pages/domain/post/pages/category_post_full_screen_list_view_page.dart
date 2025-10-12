
import 'package:flutter/material.dart';
import 'package:hbase/hbase.dart';

/// 用来构建首页的分类无限全屏 post 下拉列表页面
class CategoryPostFullScreenListViewPage extends StatelessWidget {
  final List<String> chnCodes;
  final List<TabData> tabs;
  final bool isReelOnly;
  /// 因为分页器 [ChannelTagPostPager] 目前会被多个页面共用，我想知道是哪个具体页面使用的，供后台子应用可以单独定制；
  final PageLabel pageLabel;

  const CategoryPostFullScreenListViewPage({
    super.key, 
    required this.chnCodes,
    required this.tabs,
    this.isReelOnly = false,
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
          isReelOnly: isReelOnly, 
          pageSize: 12,
          pageLabel: pageLabel
        );
        return PostFullScreenListView(
          postPager: postPager, 
          distanceCountToPreLoad: postPager.pageSize - 6,
          isShowUploadTs: tab.id == 'latest', // 前后端必须约定好为 latest.
        );
      },
    );
  }

}