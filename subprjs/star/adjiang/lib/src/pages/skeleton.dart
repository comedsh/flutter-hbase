// ignore_for_file: depend_on_referenced_packages

import 'package:adjiang/src/pages/adjiang_scaffold.dart';
import 'package:appbase/appbase.dart';
import 'package:flutter/material.dart';
import 'package:hbase/hbase.dart';
import 'package:sypages/pages.dart' hide TabData;
import 'package:ionicons/ionicons.dart';
import 'package:proste_indexed_stack/proste_indexed_stack.dart';
import 'package:visibility_detector/visibility_detector.dart';

import 'homepage/homepage.dart';
import 'hotspot/hotspot_view.dart';
import 'myspace/myspace_page.dart';
import 'commons/services/page_service.dart';


class Skeleton extends StatefulWidget {
  const Skeleton({super.key});

  @override
  State<Skeleton> createState() => _SkeletonState();
}

class _SkeletonState extends State<Skeleton> {
  
  int _current = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    debugPrint('$Skeleton dispose calls');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var display = AppServiceManager.appConfig.display as HBaseDisplay;
    return Scaffold(
      key: mainScaffoldKey,
      extendBody: true,
      body: ProsteIndexedStack(
        index: _current,
        children: [
          /// 首页
          IndexedStackChild(
            child: const AdJiangScaffold(child: HomePage()),
          ),
          /// 热榜页
          IndexedStackChild(
            child: AdJiangScaffold(
              child: HotspotView(
                chnCodes: display.chnCodes,
                tags: display.hotTags
              ),
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
              searchResultPageCreator: (String keyword) => searchResultPageCreator(keyword: keyword, chnCodes: display.chnCodes),
              hintText: '请输入爱豆的名字...',
            )
          ),
          /// 分类页
          IndexedStackChild(
            child: AdJiangScaffold(
              child: CategoryPostAlbumListViewPage(
                chnCodes: display.chnCodes,
                tabs: display.tags.map<TabData>((tag) => TabData(id: tag.code, name: tag.name)).toList(),
                isReelOnly: false,
                pageLabel: PageLabel.classifyPage,
              ),
            ),
          ),
          /// 用户中心页
          IndexedStackChild(
            child: AdJiangScaffold(
              actions: [
                PageService.darkModeSwicher,
                IconButton(
                  icon: const Icon(Ionicons.ellipsis_horizontal),
                  onPressed: () {  },
                )
              ],
              child: const MyspacePage(),
            )
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
              label: '发现',
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