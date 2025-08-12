import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hbase/hbase.dart';

import '../../post/views/demo_post_full_screen_list_view.dart';

class DemoProfilePage extends ProfilePage {

  const DemoProfilePage({super.key, required super.profile});
  
  @override
  PostAlbumListView getPostAlbumListView(PostPager postPager) {
    return PostAlbumListView(
      postPager: postPager, 
      cellClickCallback: (posts, post, postPager) async {
        return await Get.to(() => Scaffold(
          appBar: AppBar(title: Text(post.profile.name)),
          body: DemoPostFullScreenListView(
            firstPagePosts: posts,
            chosedPost: post,
            postPager: postPager, 
            distanceCountToPreLoad: postPager.pageSize - 6, 
          ),
        ));
      }
    );
  }

}