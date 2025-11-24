import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hbase/hbase.dart';

/// 用来构建分页 bottom tab page
class CategoryPostAlbumListViewPage extends StatelessWidget {
  final List<String> chnCodes;
  final List<TabData> tabs;
  final bool isReelOnly;
  /// 因为分页器 [ChannelTagPostPager] 目前会被多个页面共用，我想知道是哪个具体页面使用的，供后台子应用可以单独定制；
  final PageLabel pageLabel;

  const CategoryPostAlbumListViewPage({
    super.key, 
    required this.chnCodes, 
    required this.tabs,
    this.isReelOnly = false,
    required this.pageLabel,
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
          pageSize: 24,
          pageLabel: pageLabel
        );
        return PostAlbumListView(
          postPager: postPager, 
          isEnableAutoScroll: true,
          onCellTapped: (posts, post, postPager) async =>
            /// 当点击 cell 后会跳转到第三方页面，这里的返回值 index 是从第三方页面返回时的 post index，
            /// 这样 PostAlbumListView 根据这个值就可以进行 scrollTo 操作了
            await Get.to<int>(() => 
              PostFullScreenListViewPage(
                /// 下面 [...array] 是对原数组的 copy，避免两个页面的数据相互干扰从而导致可能出现重复的数据
                posts: [...posts], 
                post: post, 
                postPager: postPager,
                title: tab.name,
                isShowUploadTs: tab.id == 'latest',
              )) 
        );
      },
    );
  }
}