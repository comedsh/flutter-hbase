
import 'package:flutter/material.dart';
import 'package:hbase/hbase.dart';
import 'package:sycomponents/components.dart';

class CategoryPage extends StatelessWidget {
  final List<TabData> tabs;

  const CategoryPage({super.key, required this.tabs});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        appBar: AppBar(
          /// 设置透明 appbar 开始；下面的属性是设置透明 appbar 的必要属性
          elevation: 0,  // 相当于设置 z-index 值为 0，必填
          shadowColor: Colors.transparent,  // 透明 appbar 必填
          backgroundColor: Colors.transparent, // 透明 appbar 必填
          scrolledUnderElevation: 0,  // 如果不设置，拽动页面 appbar 会出现阴影；
          /// 设置透明 appbar 结束
          
          /// TabBar 必须嵌入到 title 中否则布局会留白
          title:
            TabBar(
              isScrollable: true,
              tabAlignment: TabAlignment.start, // 当 scrollable 的时候，设置第一个 tab 从最左侧开始显示，否则它会有一定的偏移。
              indicatorSize: TabBarIndicatorSize.tab,
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
              child: Container(
                alignment: Alignment.center,
                child: Text(tab.name, textScaler: const TextScaler.linear(5.0)),
              ),
            );
          }
        ).toList())
      ),
    );
  }
  
}