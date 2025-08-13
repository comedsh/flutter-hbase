import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hbase/hbase.dart';

import '../profile/pages/demo_profile_post_full_screen_list_page.dart';

class CategoryPostListPage extends StatelessWidget {
  final List<TabData> tabs;
  const CategoryPostListPage({super.key, required this.tabs});

  @override
  Widget build(BuildContext context) {
    return TabBarViewAppBarTitlePage(
      tabs: tabs,
      tabBarViewContentBuilder: (context, tab) {
        var chnCodes = ['hanbeauti'];
        var tagCodes = tab.id == 'rcmd' ? null : [tab.id];
        var postPager = ChannelTagPostPager(chnCodes: chnCodes, tagCodes: tagCodes, isReelOnly: true);
        return PostAlbumListView(postPager: postPager, onCellClicked: (posts, post, postPager) async =>
          /// 当点击 cell 后会跳转到第三方页面，这里的返回值 index 是从第三方页面返回时的 post index，
          /// 这样 PostAlbumListView 根据这个值就可以进行 scrollTo 操作了
          await Get.to<int>(() => 
            DemoProfilePostFullScreenListPage(
              posts: posts, 
              post: post, 
              postPager: postPager)) 
        );
      },
    );
  }
}