import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hbase/hbase.dart';

class MeFavoritePage extends StatelessWidget {

  /// [MeFavoritePage] 不在前端页面上直接同步用户的取消收藏状态，而是让用户自己主动下拉更新即可；
  /// 为什么这样设计详情参考 [MeLikePage]
  const MeFavoritePage({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(title: const Text('我的收藏'),),
      body: PostAlbumListView(
        postPager: MeFavoritePostPager(pageSize: 24), 
        isEnableAutoScroll: true,
        onCellClicked: (posts, post, postPager) async =>            
          /// 当点击 cell 后会跳转到第三方页面，这里的返回值 index 是从第三方页面返回时的 post index，
          /// 这样 PostAlbumListView 根据这个值就可以进行 scrollTo 操作了
          await Get.to<int>(() => 
            PostFullScreenListViewPage(
              posts: posts, 
              post: post, 
              postPager: postPager,
              title: '我的收藏'
            )) 
      )
    );
  }
}