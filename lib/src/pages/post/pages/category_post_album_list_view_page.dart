import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hbase/hbase.dart';

/// 用来构建分页 bottom tab page
class CategoryPostAlbumListViewPage extends StatelessWidget {
  final List<TabData> tabs;
  const CategoryPostAlbumListViewPage({super.key, required this.tabs});

  @override
  Widget build(BuildContext context) {
    return TabBarViewAppBarTitlePage(
      tabs: tabs,
      tabBarViewContentBuilder: (context, tab) {
        var chnCodes = ['hanbeauti'];
        var tagCodes = tab.id == 'rcmd' ? null : [tab.id];
        var postPager = ChannelTagPostPager(
          chnCodes: chnCodes, 
          tagCodes: tagCodes, 
          isReelOnly: true, 
          pageSize: 24
        );
        return PostAlbumListView(
          postPager: postPager, 
          isEnableAutoScroll: true,
          onCellClicked: (posts, post, postPager) async =>
            /// 当点击 cell 后会跳转到第三方页面，这里的返回值 index 是从第三方页面返回时的 post index，
            /// 这样 PostAlbumListView 根据这个值就可以进行 scrollTo 操作了
            await Get.to<int>(() => 
              PostFullScreenListViewPage(
                posts: posts, 
                post: post, 
                postPager: postPager,
                title: tab.name
              )) 
        );
      },
    );
  }
}