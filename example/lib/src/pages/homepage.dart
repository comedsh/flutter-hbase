import 'package:appbase/appbase.dart';
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var display = AppServiceManager.appConfig.display as HBaseDisplay;
    return Scaffold(
      body: ProsteIndexedStack(
        index: _current,
        children: [
          IndexedStackChild(
            child: CategoryPostFullScreenListViewPage(             
              /*
                // 保留下面的 demo code，可以清晰的看到数据是如何构建的
                chnCodes: const ['hanbeauti', 'life'],
                tabs: [
                  TabData(id: 'rcmd', name: '推荐'),
                  TabData(id: 'omei', name: '欧美'),
                  TabData(id: 'rhan', name: '日韩'),
                  TabData(id: 'xmt', name: '新马泰'),
                  TabData(id: 'qita', name: '其它'),
                ]
              */
              chnCodes: display.chnCodes,
              tabs: display.tags.map<TabData>((tag) => TabData(id: tag.code, name: tag.name)).toList(),
              isReelOnly: true,
              pageLabel: PageLabel.homePage,
            ),
          ),
          IndexedStackChild(
            child: HotspotProfilePage(
              chnCodes: display.chnCodes,
              tags: display.hotTags,
            )
          ),
          IndexedStackChild(
            child: CategoryPostAlbumListViewPage(
              chnCodes: display.chnCodes,
              tabs: display.tags.map<TabData>((tag) => TabData(id: tag.code, name: tag.name)).toList(),
              isReelOnly: false,
              pageLabel: PageLabel.classifyPage
            ),
          ),
          IndexedStackChild(
            child: const MePage()
          ),
        ]
      ),
      bottomNavigationBar: BottomNavigationBar(
        /// 务必设置为 Colors.black，在真机环境下，之前设置为 Colors.black54 或者 Colors.black87，并且在 reel 使用 BoxFit.cover 
        /// 的布局下的翻页的过程中，在 BottomNavigationBar 中可以看到 unblur 的内容，但是如果改成 BoxFit.contain 却不会；其原因未知，
        /// 但是可以猜测是和 Blur + BoxFit.cover + BottomNavigationBar 的背景色有关，BoxFit.cover 会撑大屏幕并且超出屏幕范围，导致
        /// BottomNavigationBar 其它颜色被覆盖？使用了 evalutaton 100 也是无效的；为了能够使用最佳的单 Reel 的翻页的体验，必须使用
        /// BoxFit.cover，因此只能这里妥协，设置为 Colors.black；具；需要额外注意的是，在模拟器上有没有这样的问题...
        backgroundColor: Colors.black,
        // 如果超过 3 个 bar items 则必须添加
        type: BottomNavigationBarType.fixed,
        onTap: (int index) { 
          setState(() => _current = index);
          ScoreService.notifyScoreSimple();
        },
        currentIndex: _current,
        items: [
          BottomNavigationBarItem(
            activeIcon: const Icon(Ionicons.play_circle),
            icon: const Icon(Ionicons.play_circle_outline),
            label: AppServiceManager.appConfig.i ? '首页' : '视频',
          ),
          const BottomNavigationBarItem(
            activeIcon: Icon(Icons.local_fire_department, size: 26,),
            icon: Icon(Icons.local_fire_department_outlined, size: 26),
            label: '热榜',
          ),
          const BottomNavigationBarItem(
            activeIcon: Icon(Ionicons.apps),
            icon: Icon(Ionicons.apps_outline),
            label: '分类',
          ),
          const BottomNavigationBarItem(
            activeIcon: Icon(Ionicons.person),
            icon: Icon(Ionicons.person_outline),
            label: '我',
          ),
        ]
      ),
    );
  }
}