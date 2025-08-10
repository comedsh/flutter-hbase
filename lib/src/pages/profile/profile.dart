import 'package:flutter/material.dart';
import 'package:hbase/hbase.dart';
import 'package:hbase/src/pages/profile/components/profile_intro_panel.dart';
import 'package:sycomponents/components.dart';

class ProfilePage extends StatelessWidget {
  final Profile profile;
  const ProfilePage({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
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
        body: TabbarViewBodyPage(tabs: [TabData(id: '01', name: '热门'), TabData(id: '02', name: "最近更新")],)
      )
    );
  }

}