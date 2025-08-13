import 'package:example/src/pages/post/views/demo_full_screen_post_view.dart';
import 'package:flutter/material.dart';
import 'package:hbase/hbase.dart';

class DemoPostFullScreenListView extends PostFullScreenListView {
  const DemoPostFullScreenListView({
    super.key, 
    super.firstPagePosts,
    super.chosedPost,
    required super.postPager, 
    required super.distanceCountToPreLoad
  });

  @override
  State<DemoPostFullScreenListView> createState() => DemoPostFullScreenListPageState();
}

class DemoPostFullScreenListPageState extends PostFullScreenListViewState<DemoPostFullScreenListView> {
  
  @override
  PostFullScreenView createFullScreenPostView(Post post, int postIndex) {
    return DemoFullScreenPostView(post: post, postIndex: postIndex,);
  }
}