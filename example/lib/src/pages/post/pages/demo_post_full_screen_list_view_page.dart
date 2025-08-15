import 'package:hbase/hbase.dart';

import '../../post/views/demo_post_full_screen_list_view.dart';

class DemoPostFullScreenListViewPage extends PostFullScreenListViewPage {

  const DemoPostFullScreenListViewPage({
    super.key, 
    required super.posts, 
    required super.post, 
    required super.postPager,
    required super.title
  });

  @override
  getPostFullScreenListView({List<Post>? posts, Post? post, required Pager<Post> postPager}) {
    return DemoPostFullScreenListView(
      firstPagePosts: posts,
      chosedPost: post,
      postPager: postPager, 
      distanceCountToPreLoad: postPager.pageSize - 6, 
    );
  }

}