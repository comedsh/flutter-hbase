import 'package:flutter/material.dart';
import 'package:hbase/hbase.dart';

class MeFollowPage extends StatelessWidget {
  const MeFollowPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('我的关注')),
      body: ProfileListView(pager: MeFollowProfilePager())
    );
  }
}