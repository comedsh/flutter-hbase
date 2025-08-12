import 'package:hbase/hbase.dart';

import '../../post/views/demo_post_full_screen_list_view.dart';

class DemoProfilePostFullScreenListPage extends ProfilePostFullScreenListPage {

  const DemoProfilePostFullScreenListPage({
    super.key, 
    required super.posts, 
    required super.post, 
    required super.postPager
  });

  @override
  getPostFullScreenListView(List<Post> posts, post, postPager) {
    return DemoPostFullScreenListView(
      firstPagePosts: posts,
      chosedPost: post,
      postPager: postPager, 
      distanceCountToPreLoad: postPager.pageSize - 6, 
    );
  }

}