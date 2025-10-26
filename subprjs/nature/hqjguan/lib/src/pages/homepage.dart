// ignore_for_file: depend_on_referenced_packages

import 'package:appbase/appbase.dart';
import 'package:flutter/material.dart';
import 'package:hbase/hbase.dart';
import 'package:sypages/pages.dart' hide TabData;
import 'package:ionicons/ionicons.dart';
import 'package:proste_indexed_stack/proste_indexed_stack.dart';
import 'package:visibility_detector/visibility_detector.dart';


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
      key: mainScaffoldKey,
      // MeHome 暂时不能支持 extendBody 否则 ListView 的样式会有问题
      extendBody: _current != 4,
      body: ProsteIndexedStack(
        index: _current,
        children: [
          /// 首页
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
          /// 热榜页
          IndexedStackChild(
            child: HotspotProfilePage(
              chnCodes: display.chnCodes,
              tags: display.hotTags,
              showHotPosts: true,
            )
          ),
          /// 搜索页
          IndexedStackChild(
            child: SearchBarInAppBar(
              // 想了想还是展示 leading button 吧，这样布局上好看些。
              appBarAutomaticallyImplyLeading: false,
              isEmptyFocusToShowKeywordListPage: false,
              flashPageCreator: (TextEditingController controller) => flashPageCreator(controller),
              keywordsListPageCreator: (TextEditingController controller) => searchKeywordListPage(controller),
              searchResultPageCreator: (String keyword) => searchPostResultPageCreator(keyword: keyword, chnCodes: display.chnCodes),
            )
          ),
          /// 分类页
          IndexedStackChild(
            child: CategoryPostAlbumListViewPage(
              chnCodes: display.chnCodes,
              tabs: display.tags.map<TabData>((tag) => TabData(id: tag.code, name: tag.name)).toList(),
              isReelOnly: false,
              pageLabel: PageLabel.classifyPage,
            ),
          ),
          /// 用户中心页
          IndexedStackChild(
            child: const MePage()
          ),
        ]
      ),
      bottomNavigationBar: VisibilityDetector(
        key: const Key('hqjguan-bottom-navbar'),
        onVisibilityChanged: (info) => info.visibleFraction >= 0.8
          ? HBaseStateService.setBottomNavigationBarVisible(true)
          : HBaseStateService.setBottomNavigationBarVisible(false),          
        child: LiquidGlassBottomBar(
          /// 务必设置为 Colors.black，在真机环境下，之前设置为 Colors.black54 或者 Colors.black87，并且在 reel 使用 BoxFit.cover 
          /// 的布局下的翻页的过程中，在 BottomNavigationBar 中可以看到 unblur 的内容，但是如果改成 BoxFit.contain 却不会；其原因未知，
          /// 但是可以猜测是和 Blur + BoxFit.cover + BottomNavigationBar 的背景色有关，BoxFit.cover 会撑大屏幕并且超出屏幕范围，导致
          /// BottomNavigationBar 其它颜色被覆盖？使用了 evalutaton 100 也是无效的；为了能够使用最佳的单 Reel 的翻页的体验，必须使用
          /// BoxFit.cover，因此只能这里妥协，设置为 Colors.black；具；需要额外注意的是，在模拟器上有没有这样的问题...
          // backgroundColor: Colors.black,
          // 如果超过 3 个 bar items 则必须添加
          // type: BottomNavigationBarType.fixed,
          key: bottomNavigationBarKey,
          onTap: (int index) { 
            setState(() => _current = index);
            ScoreService.notifyScoreSimple();
          },
          currentIndex: _current,
          activeColor: AppServiceManager.appConfig.appTheme.seedColor,
          items: [
            LiquidGlassBottomBarItem(
              activeIcon: Ionicons.play_circle,
              icon: Ionicons.play_circle_outline,
              label: AppServiceManager.appConfig.i ? '首页' : '视频',
            ),
            const LiquidGlassBottomBarItem(
              activeIcon: Ionicons.flame,
              icon: Ionicons.flame_outline,
              label: '热榜',
            ),
            const LiquidGlassBottomBarItem(
              activeIcon: Ionicons.search,
              icon: Ionicons.search_outline,
              label: '搜索',
            ),
            const LiquidGlassBottomBarItem(
              activeIcon: Ionicons.apps,
              icon: Ionicons.apps_outline,
              label: '分类',
            ),
            const LiquidGlassBottomBarItem(
              activeIcon: Ionicons.person,
              icon: Ionicons.person_outline,
              label: '我',
            ),
          ]
        ),
      ),
    );
  }
}