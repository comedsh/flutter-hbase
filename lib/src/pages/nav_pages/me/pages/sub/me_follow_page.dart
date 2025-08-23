import 'package:flutter/material.dart';
import 'package:hbase/hbase.dart';

class MeFollowPage extends StatelessWidget {

  /// [MeFavoritePage] 不在前端页面上直接同步用户的取消关注状态（这里是指从列表中删除），而是让用户自己
  /// 主动下拉更新即可；为什么这样设计详情参考 [MeLikePage]  
  const MeFollowPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('我的关注')),
      body: ProfileListView(pager: MeFollowProfilePager())
    );
  }
}