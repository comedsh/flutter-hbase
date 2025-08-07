import 'package:example/src/pages/post/demo_full_screen_post.dart';
import 'package:flutter/material.dart';
import 'package:hbase/hbase.dart';

class DemoPostFullScreenListPage extends PostFullScreenListPage {
  const DemoPostFullScreenListPage({
    super.key, 
    super.firstPagePosts,
    super.chosedPost,
    required super.postPager, 
    required super.distanceCountToPreLoad
  });

  @override
  State<DemoPostFullScreenListPage> createState() => DemoPostFullScreenListPageState();
}

class DemoPostFullScreenListPageState extends PostFullScreenListPageState<DemoPostFullScreenListPage> {
  
  @override
  FullScreenPostPage createFullScreenPostPage(Post post) {
    return DemoFullScreenPostPage(post: post);
  }
}