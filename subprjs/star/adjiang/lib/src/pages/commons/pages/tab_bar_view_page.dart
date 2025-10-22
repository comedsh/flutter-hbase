
// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:appbase/appbase.dart';
import 'package:hbase/hbase.dart';
import 'package:sycomponents/components.dart';

class TabBarViewPage extends StatelessWidget {
  final List<TabData> tabs;
  final TabBarViewContentBuilder tabBarViewContentBuilder;
  final int? initialIndex;
  /// 是否让 body 延伸到 appbar 中，如果要延伸那么需要设置透明 appbar 并且外加 appbarMask
  final bool isExtendBodyBehindAppBar;

  /// [TabBar] 是嵌入 appbar 中的
  const TabBarViewPage({
    super.key, 
    required this.tabs, 
    required this.tabBarViewContentBuilder, 
    this.initialIndex,
    this.isExtendBodyBehindAppBar = false
  });

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: initialIndex ?? 0,
      length: tabs.length,
      child: Scaffold(
        appBar: AppBar(
          /** 设置透明 appbar */
          elevation: isExtendBodyBehindAppBar ? 0 : null,  // 相当于设置 z-index 值为 0，必填
          shadowColor: isExtendBodyBehindAppBar ? Colors.transparent : null,  // 透明 appbar 必填
          backgroundColor: isExtendBodyBehindAppBar ? Colors.transparent : null, // 透明 appbar 必填
          scrolledUnderElevation: isExtendBodyBehindAppBar ? 0 : null,  // 如果不设置，拽动页面 appbar 会出现阴影；
          flexibleSpace: isExtendBodyBehindAppBar ? MyAppBar.appbarMask(context) : null,         
          title:
            TabBar(
              isScrollable: true,
              tabAlignment: TabAlignment.start, // 当 scrollable 的时候，设置第一个 tab 从最左侧开始显示，否则它会有一定的偏移。
              indicatorSize: TabBarIndicatorSize.tab,
              indicatorColor: AppServiceManager.appConfig.appTheme.seedColor,
              labelStyle: TextStyle(fontSize: sp(20.0), fontWeight: FontWeight.bold),
              unselectedLabelStyle: TextStyle(fontSize: sp(14.0)),
              indicator: const BoxDecoration(), // 取消选中的下划线
              indicatorPadding: EdgeInsets.zero, // 取消任何的 padding
              dividerHeight: 0.0, // 去掉贯穿整个屏幕的下划线
              tabs: tabs
                .map((tab) => Tab(text: tab.name))
                .toList()
            ),
        ),
        body: TabBarView(
          children: tabs.map((tab) {
            /// 使用 [KeepAliveWrapper] 的目的是为了避免在切换 tab 的时候重新创建 TabView
            return KeepAliveWrapper(
              child: tabBarViewContentBuilder(context, tab)
            );
          }
        ).toList()),
        extendBodyBehindAppBar: isExtendBodyBehindAppBar
      ),
    );
  }
  
}