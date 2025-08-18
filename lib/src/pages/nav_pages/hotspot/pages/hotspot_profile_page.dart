import 'package:flutter/material.dart';
import 'package:hbase/hbase.dart';
import 'package:sycomponents/components.dart';

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
            SliverToBoxAdapter(
              child: HotspotProfileCardSwiperView(
                chnCodes: chnCodes,
                tags: tags,              
              )
            ),
            SliverToBoxAdapter(child: SizedBox(height: sp(20)))            
          ];
        }, 
        body: DefaultTabController(
          length: 1,
          child: Column(
            children: [
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