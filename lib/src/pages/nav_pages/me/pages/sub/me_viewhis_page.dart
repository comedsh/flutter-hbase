import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hbase/hbase.dart';


class MeViewhisPage extends StatelessWidget {

  const MeViewhisPage({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(title: const Text('我浏览记录'),),
      body: PostAlbumListView(
        postPager: MeViewhisPostPager(pageSize: 24), 
        isEnableAutoScroll: true,
        onCellTapped: (posts, post, postPager) async =>            
          /// 当点击 cell 后会跳转到第三方页面，这里的返回值 index 是从第三方页面返回时的 post index，
          /// 这样 PostAlbumListView 根据这个值就可以进行 scrollTo 操作了
          await Get.to<int>(() => 
            PostFullScreenListViewPage(
              posts: posts, 
              post: post, 
              postPager: postPager,
              title: '我的浏览记录'
            )) 
      )
    );
  }
}