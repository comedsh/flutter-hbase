import 'package:flutter/material.dart';
import 'package:hbase/src/pages/nav_pages/me/views/me_subscr_info_view.dart';

class MePage extends StatelessWidget {
  final String? title;
  const MePage({super.key, this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title ?? '我的'),
      ),
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget> [
            const SliverToBoxAdapter(
              child: MeSubscrInfoView()
            ),
          ];
        },
        body: Column(children: [],),
      )
    );
  }
}