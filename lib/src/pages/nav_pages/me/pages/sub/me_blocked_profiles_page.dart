import 'package:flutter/material.dart';
import 'package:hbase/hbase.dart';

class MeBlockedProfilesPage extends StatelessWidget {

  /// [MeBlockedProfilesPage] 不在前端页面上直接同步用户的取消收藏状态，而是让用户自己主动下拉更新即可；
  /// 为什么这样设计详情参考 [MeLikePage]
  const MeBlockedProfilesPage({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(title: const Text('我拉黑的用户列表'),),
      body: const BlockedProfileListView()
    );
  }
}