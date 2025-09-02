import 'package:flutter/material.dart';
import 'package:hbase/hbase.dart';
import 'package:ionicons/ionicons.dart';
import 'package:proste_indexed_stack/proste_indexed_stack.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  
  int _current = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    debugPrint('$HomePage dispose calls');
    Colors.deepOrange;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ProsteIndexedStack(
        index: _current,
        children: [
          IndexedStackChild(
            child: CategoryPostFullScreenListViewPage(
              chnCodes: const ['hanbeauti', 'life'],
              tabs: [
                TabData(id: 'rcmd', name: '推荐'),
                TabData(id: 'omei', name: '欧美'),
                TabData(id: 'rhan', name: '日韩'),
                TabData(id: 'xmt', name: '新马泰'),
                TabData(id: 'qita', name: '其它'),
              ]
            ),
          ),
          IndexedStackChild(
            child: HotspotProfilePage(
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
          IndexedStackChild(
            child: CategoryPostAlbumListViewPage(tabs: [
              TabData(id: 'rcmd', name: '推荐'),
              TabData(id: 'omei', name: '欧美'),
              TabData(id: 'rhan', name: '日韩'),
              TabData(id: 'xmt', name: '新马泰'),
              TabData(id: 'qita', name: '其它')
            ]),
          ),
          IndexedStackChild(
            child: const MePage()
          ),
        ]
      ),
      bottomNavigationBar: BottomNavigationBar(
        /// 务必设置为 Colors.black，在真机环境下，之前设置为 Colors.black54 或者 Colors.black87，并且在 reel 使用 BoxFit.cover 
        /// 的布局下的翻页的过程中，在 BottomNavigationBar 中可以看到 unblur 的内容，但是如果改成 BoxFit.contain 却不会；体原因未知，
        /// 但是可以猜测是和 Blur + BoxFit.cover + BottomNavigationBar 的背景色有关，BoxFit.cover 会撑大屏幕并且超出屏幕范围，导致
        /// BottomNavigationBar 其它颜色被覆盖？使用了 evalutaton 100 也是无效的；为了能够使用最佳的单 Reel 的翻页的体验，必须使用
        /// BoxFit.cover，因此只能这里妥协，设置为 Colors.black；具；需要额外注意的是，在模拟器上有没有这样的问题...
        backgroundColor: Colors.black,
        // 如果超过 3 个 bar items 则必须添加
        type: BottomNavigationBarType.fixed,
        onTap: (int index) => setState(() => _current = index),
        currentIndex: _current,
        items: const [
          BottomNavigationBarItem(
            activeIcon: Icon(Ionicons.play_circle),
            icon: Icon(Ionicons.play_circle_outline),
            label: '视频',
          ),
          BottomNavigationBarItem(
            activeIcon: Icon(Icons.local_fire_department, size: 26,),
            icon: Icon(Icons.local_fire_department_outlined, size: 26),
            label: '热榜',
          ),
          BottomNavigationBarItem(
            activeIcon: Icon(Ionicons.apps),
            icon: Icon(Ionicons.apps_outline),
            label: '分类',
          ),
          BottomNavigationBarItem(
            activeIcon: Icon(Ionicons.person),
            icon: Icon(Ionicons.person_outline),
            label: '我',
          ),
        ]
      ),
    );
  }
}