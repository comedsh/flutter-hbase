import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hbase/hbase.dart';


abstract class PostFullScreenListViewPage extends StatelessWidget {
  /// 初始化的 posts
  final List<Post>? posts;
  /// 跳转进入的 post, 该 post 一定是 [posts] 中的一员
  final Post? post;  
  final Pager<Post> postPager;
  final String? title;
  const PostFullScreenListViewPage({
    super.key, 
    required this.postPager,
    this.posts, 
    this.post, 
    this.title
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
          title: title != null ? Text(title!) : null,
          leading: BackButton(onPressed: () {
            /// 注意，默认主页面是不需要刷新的即 [PglNavBackResult.isNeedRefresh] 只为 false，如果需要将其设为 true，
            /// 可以像 Qiyan 的 [MySpaceTabsPage] 中那样，捕获返回值，然后重新构建 PglNavBackResult 返回即可
            Get.back<int>(result: pageChangedIndex);
          }),
        ),
        body: getPostFullScreenListView(posts: posts, post: post, postPager: postPager)
      ),
    );
  }

  getPostFullScreenListView({List<Post>? posts, Post? post, required Pager<Post> postPager});
}