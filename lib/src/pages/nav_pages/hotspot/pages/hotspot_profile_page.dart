import 'package:flutter/material.dart';
import 'package:hbase/hbase.dart';
import 'package:sycomponents/components.dart';

/// [tags] 是分类 profile 榜单，但是 [tags] 可以为空，因此如果为空则不展示
class HotspotProfilePage extends StatelessWidget {
  final List<String> chnCodes;
  final List<ChannelTag> tags;
  const HotspotProfilePage({super.key, required this.chnCodes, required this.tags});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('热榜'),),
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget> [
            if (tags.isNotEmpty)
              ... [
                SliverToBoxAdapter(
                  child: HotspotProfileCardSwiperView(
                    chnCodes: chnCodes,
                    tags: tags,              
                  )
                ),
                SliverToBoxAdapter(child: SizedBox(height: sp(20)))
              ]
            else 
              SliverToBoxAdapter(child: Container())
          ];
        }, 
        body: DefaultTabController(
          length: 1,
          child: Column(
            children: [
              /// 当且仅当需要展示上一层的分类榜单这里才需要展示子标题“推荐”否则不用展示
              if (tags.isNotEmpty)
                TabBar(
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelStyle: TextStyle(fontSize: sp(20.0), fontWeight: FontWeight.bold),
                  unselectedLabelStyle: TextStyle(fontSize: sp(14.0)),
                  indicator: const BoxDecoration(), // 取消选中的下划线
                  indicatorPadding: EdgeInsets.zero, // 取消任何的 padding
                  dividerHeight: 0.0, // 去掉贯穿整个屏幕的下划线
                  tabs: const [Tab(text: '推荐')]
                ),
              Expanded(
                child: TabBarView(
                  children: [
                    /// 使用 [KeepAliveWrapper] 的目的是为了避免在切换 tab 的时候重新创建 TabView
                    KeepAliveWrapper(
                      child: HotspotProfileListView(
                        chnCodes: chnCodes,
                      )
                    )
                  ]
                ),
              )
            ]
          ),
        ),
      )  
    );
  }
}