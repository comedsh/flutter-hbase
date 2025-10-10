import 'package:flutter/material.dart';
import 'package:hbase/hbase.dart';
import 'package:sycomponents/components.dart';

/// [tags] 是分类 profile 榜单，但是 [tags] 可以为空，因此如果为空则不展示
class HotspotProfilePage extends StatelessWidget {
  final List<String> chnCodes;
  /// 作为 [HotspotProfileCardSwiperView] 组件的核心构造参数，如果该数组为空，则表示不展示该组件
  final List<ChannelTag> tags;
  /// 像 nature 这样的应用，因为 tags 数不足，因此无法展示 [HotspotProfileCardSwiperView] 组价，为了使得
  /// 该页面不那么的空，因此通过 [showHotPosts] 来控制是否展示 [HotspotPostCardSwiperView] 组件；
  final bool? showHotPosts;

  const HotspotProfilePage({
    super.key, 
    required this.chnCodes, 
    required this.tags,
    this.showHotPosts = false
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('热榜'),),
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget> [
            /// 心得：总算是将 flutter 中的 if else 搞明白了
            if (isHeaderVisible)
              if (isHotspotProfileCardSwiperViewVisible)
                ... [
                  SliverToBoxAdapter(
                    child: HotspotProfileCardSwiperView(
                      chnCodes: chnCodes,
                      tags: tags,              
                    )
                  ),
                  SliverToBoxAdapter(child: SizedBox(height: sp(20)))
                ]
              , // 核心：两个并排的 if 必须使用 , 隔断否则语法报错
              if (showHotPosts == true)
                ... [
                  // SliverToBoxAdapter(child: 
                  //   Center(
                  //     child: Padding(
                  //       padding: EdgeInsets.symmetric(vertical: sp(22)),
                  //       child: Text('热门帖子', style: TextStyle(
                  //         fontSize: sp(20.0), 
                  //         fontWeight: FontWeight.bold, 
                  //         color: Colors.amber)
                  //       ),
                  //     ),
                  //   ),
                  // ),
                  SliverToBoxAdapter(child: HotspotPostCardSwiperView(chnCodes: chnCodes,)),
                  SliverToBoxAdapter(child: SizedBox(height: sp(20)))
                ]
            // 不展示 header 但是不能返回空，因此直接返回一个空的 Container 回去即可
            else 
              SliverToBoxAdapter(child: Container())
          ];
        }, 
        body: DefaultTabController(
          length: 1,
          child: Column(
            children: [
              /// 当且仅当需要展示上一层的分类榜单这里才需要展示子标题“推荐”否则不用展示
              if (isHeaderVisible)
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

  get isHotspotProfileCardSwiperViewVisible => tags.isNotEmpty;

  get isHeaderVisible => isHotspotProfileCardSwiperViewVisible || showHotPosts == true;
}