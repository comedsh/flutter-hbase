import 'package:get/get.dart';
import 'package:hbase/hbase.dart';

import '../../post/pages/demo_post_full_screen_list_view_page.dart';


class DemoProfilePage extends ProfilePage {

  const DemoProfilePage({super.key, required super.profile});
  
  @override
  PostAlbumListView getPostAlbumListView(Pager<Post> postPager) {
    return PostAlbumListView(
      postPager: postPager, 
      onCellClicked: (posts, post, postPager) async =>
        /// 当点击 cell 后会跳转到第三方页面，这里的返回值 index 是从第三方页面返回时的 post index，
        /// 这样 PostAlbumListView 根据这个值就可以进行 scrollTo 操作了
        await Get.to<int>(() => 
          DemoPostFullScreenListViewPage(
            posts: posts, 
            post: post, 
            postPager: postPager,
            title: post.profile.name
          ))
    );
  }

}