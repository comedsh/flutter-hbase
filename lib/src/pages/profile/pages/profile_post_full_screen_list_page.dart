import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hbase/hbase.dart';

/// 目前该页面的应用场景仅是通过 [ProfilePage] 中的 [PostAlbumListView] 中的 cell 点击后进入；因此目前仅考虑
/// 这种场景来快速实现的，将来如果有更多的场景的话，再考虑如何扩展
abstract class ProfilePostFullScreenListPage extends StatelessWidget {
  /// 通过 [PostAlbumListView] 已加载的 posts
  final List<Post> posts;
  /// 跳转进入的 post
  final Post post;  
  final PostPager postPager;
  const ProfilePostFullScreenListPage({
    super.key, 
    required this.posts, 
    required this.post, 
    required this.postPager
  });

  @override
  Widget build(BuildContext context) {
    late int pageChangedIndex;
    return NotificationListener<PostPageChangedNotification>(
      onNotification: (PostPageChangedNotification notification) {
        pageChangedIndex = notification.index;
        debugPrint('$PostPageChangedNotification has been caught, pageChangedIndex: $pageChangedIndex');
        return true;  // 阻止冒泡
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(post.profile.name),
          leading: BackButton(onPressed: () {
            /// 注意，默认主页面是不需要刷新的即 [PglNavBackResult.isNeedRefresh] 只为 false，如果需要将其设为 true，
            /// 可以像 Qiyan 的 [MySpaceTabsPage] 中那样，捕获返回值，然后重新构建 PglNavBackResult 返回即可
            Get.back<int>(result: pageChangedIndex);
          }),
        ),
        body: getPostFullScreenListView(posts, post, postPager)
      ),
    );
  }

  getPostFullScreenListView(List<Post> posts, Post post, PostPager postPager);
}