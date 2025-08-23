import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hbase/hbase.dart';


class MeLikePage extends StatelessWidget {

  /// 取消喜欢如何同步？之前有想过，当用户从 [PostFullScreenListViewPage] 将取消喜欢的 posts 缓存起来，
  /// 在返回给 [MeLikePage] 的时候，将删除的 posts 从 [PostAlbumListView] 中删除，当然没那么简单，最终
  /// 是需要从 pagingController 中删除，但是问题来了，如果这样硬删除的话，会导致分页状态不同步，会导致 BUG；
  /// 因此最终放弃这样做，即不在用户返回 [MeLikePage] 的时候立刻硬同步，而是让用户自己去下拉一下更新即可。
  /// 
  const MeLikePage({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(title: const Text('我的喜欢'),),
      body: PostAlbumListView(
        postPager: MeLikePostPager(pageSize: 24), 
        isEnableAutoScroll: true,
        onCellClicked: (posts, post, postPager) async =>            
          /// 当点击 cell 后会跳转到第三方页面，这里的返回值 index 是从第三方页面返回时的 post index，
          /// 这样 PostAlbumListView 根据这个值就可以进行 scrollTo 操作了
          await Get.to<int>(() => 
            PostFullScreenListViewPage(
              posts: posts, 
              post: post, 
              postPager: postPager,
              title: '我的喜欢'
            )) 
      )
    );
  }
}