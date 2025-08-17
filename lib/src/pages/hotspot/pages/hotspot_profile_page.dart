import 'package:flutter/material.dart';
import 'package:hbase/hbase.dart';
import 'package:hbase/src/pages/hotspot/views/hotspot_profile_list_view.dart';
import 'package:sycomponents/components.dart';

class HotspotProfilePage extends StatelessWidget {
  const HotspotProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('热榜'),),
      /// FIXME chnCodes and ChannelTags should loaded from backend
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget> [
            SliverToBoxAdapter(
              child: HotspotProfileCardSwiperView(
                chnCodes: const ['hanbeauti', 'life'],
                tags: [
                  ChannelTag(code: 'omei', name: '欧美'),
                  ChannelTag(code: 'korea', name: '韩国'),
                  ChannelTag(code: 'xmt',  name: '新马泰'),
                  ChannelTag(code: 'twan', name: '台湾'),
                  ChannelTag(code: 'japan', name: '日本'),
                  ChannelTag(code: 'dalu', name: '其它'), // 把内地的命名为其它保险一些 
                ],              
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
              const Expanded(
                child: TabBarView(
                  children: [
                    /// 使用 [KeepAliveWrapper] 的目的是为了避免在切换 tab 的时候重新创建 TabView
                    KeepAliveWrapper(
                      child: HotspotProfileListView(
                        chnCodes: ['hanbeauti', 'life'],
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