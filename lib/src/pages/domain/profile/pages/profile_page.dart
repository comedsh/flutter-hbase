import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hbase/hbase.dart';
import 'package:hbase/src/pages/domain/profile/views/profile_statistics_intro_panel.dart';

typedef PostAlbumListCreator = PostAlbumListView Function({
  required Pager<Post> post, 
  required OnCellClicked cellClickCallback
});

class ProfilePage extends StatelessWidget {
  final Profile profile;
  const ProfilePage({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    var tabDatas = [ 
      TabData(id: 'hot', name: '热门'), 
      TabData(id: 'new', name: "最新", isDefault: true)
    ];
    return Scaffold(
      appBar: AppBar(
        title: Text(profile.name)
      ),
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget> [
            SliverToBoxAdapter(child: ProfileStatisticsIntroPanel(profile: profile))
          ];
        }, 
        body: TabBarViewBodyPage(
          tabs: tabDatas,
          initialIndex: TabService.getDefaultIndex(tabDatas),
          tabBarViewContentBuilder: (BuildContext context, TabData tab) {
            var postPager = ProfilePostPager(profileCode: profile.code, sortBy: tab.id, pageSize: 24);
            return PostAlbumListView(
              postPager: postPager, 
              onCellClicked: (posts, post, postPager) async =>
                /// 当点击 cell 后会跳转到第三方页面，这里的返回值 index 是从第三方页面返回时的 post index，
                /// 这样 PostAlbumListView 根据这个值就可以进行 scrollTo 操作了
                await Get.to<int>(() => 
                  PostFullScreenListViewPage(
                    posts: posts, 
                    post: post, 
                    postPager: postPager,
                    title: post.profile.name
                  ))
            );
          },
        )
      )
    );
  }
}