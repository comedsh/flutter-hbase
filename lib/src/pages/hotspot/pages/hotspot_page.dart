import 'package:flutter/material.dart';
import 'package:hbase/hbase.dart';

class HotspotPage extends StatelessWidget {
  const HotspotPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('热榜'),),
      /// FIXME chnCodes and ChannelTags should loaded from backend
      body: HotspotCardSwiperView(
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
    );
  }
}