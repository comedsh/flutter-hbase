import 'package:flutter/material.dart';
import 'package:hbase/hbase.dart';
import 'package:hbase/src/pages/profile/components/profile_intro_panel.dart';

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
            SliverToBoxAdapter(child: ProfileIntroPanel(profile: profile))
          ];
        }, 
        body: TabBarViewBodyPage(
          tabs: tabDatas,
          initialIndex: TabService.getDefaultIndex(tabDatas),
          tabBarViewContentBuilder: (BuildContext context, TabData tab) {
            var postPager = ProfilePostPager(profileCode: profile.code, sortBy: tab.id, pageSize: 24);
            return PostAlbumList(postPager: postPager);
          },
        )
      )
    );
  }

}