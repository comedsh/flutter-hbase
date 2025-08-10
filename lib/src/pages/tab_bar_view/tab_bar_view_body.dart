
import 'package:flutter/material.dart';
import 'package:hbase/hbase.dart';
import 'package:sycomponents/components.dart';

class TabbarViewBodyPage extends StatelessWidget {
  final List<TabData> tabs;

  /// [TabBar] 是嵌入 body 中的
  const TabbarViewBodyPage({super.key, required this.tabs});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: tabs.length,
      child: Column(
        children: [
        /**
          * (重要文档)
          * 有关 TabBar 的定义如下，
          * 1. 隐藏 TabBar 默认的选中下划线（indicator）和一条很浅的贯穿整个屏幕的下划线
          *    a. 设置 indicator: const BoxDecoration() 即可隐藏选中下划线；
          *    b. 另外 TabBar 还有一条浅灰色的贯穿整个屏幕的下划线，可以通过 dividerHeight: 0.0 去掉
          *    设置该条件的前提是把 TabBar 放到了 AppBar.bottom 中
          * 2. 设置选中字体样式，很简单，我只想要把选中字体样式变大变粗。通过 unselectedLabelStyle 设置未选中字体样式 + labelStyle 设置
          *    选中字体样式即可实现。
          * 3. 每一个 tab 字体的宽度；特别注意，默认情况下，TabBar 是不允许滑动的，也就是说，所有内容都挤在当前屏幕中展示；因此如果 tabs 
          *    过多的话，就会挤压 tab 的空间使得 tab 文字展示不完整，因此为了解决这个问题，只需要设置 isScrollable 为 true 即可，同时
          *    需要设置 tabAlignment 为 TabAlignment.start，这样使得第一个 tab 是从屏幕的最左侧显示，否则会有一定的向右偏移距离。
          * ---
          * 原来 TabBar 是可以放到任意位置的，以前以为只能放到 AppBar.bottom 中，现在直接放到 body 中也是可以的；借助这一特性，使得可以
          * 使得通过 BottomNavigationBar 切换页面后可以利用 IndexedStack 来保存各个页面之前的状态，如何实现的参考下面的代码实现；TabBar
          * 可以放到任何位置的灵感来自于 https://pub.dev/packages/buttons_tabbar；
          *  
          * 因此将 TabBar 的实现挪动到 body 中了 - 也因此 hide appbar 的实现应该就可以变得异常的简单了。
          */
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
          Expanded(
            child: TabBarView(
              children: tabs.map((tab) {
                /// 使用 [KeepAliveWrapper] 的目的是为了避免在切换 tab 的时候重新创建 TabView
                return KeepAliveWrapper(
                  child: Container(
                    alignment: Alignment.center,
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Text(tab.name, textScaler: const TextScaler.linear(5.0)),
                          Text(tab.name, textScaler: const TextScaler.linear(5.0)),
                          Text(tab.name, textScaler: const TextScaler.linear(5.0)),
                          Text(tab.name, textScaler: const TextScaler.linear(5.0)),
                          Text(tab.name, textScaler: const TextScaler.linear(5.0)),
                          Text(tab.name, textScaler: const TextScaler.linear(5.0)),
                          Text(tab.name, textScaler: const TextScaler.linear(5.0)),
                          Text(tab.name, textScaler: const TextScaler.linear(5.0)),
                          Text(tab.name, textScaler: const TextScaler.linear(5.0)),
                          Text(tab.name, textScaler: const TextScaler.linear(5.0)),
                          Text(tab.name, textScaler: const TextScaler.linear(5.0)),
                          Text(tab.name, textScaler: const TextScaler.linear(5.0)),
                          Text(tab.name, textScaler: const TextScaler.linear(5.0)),
                          Text(tab.name, textScaler: const TextScaler.linear(5.0)),
                          Text(tab.name, textScaler: const TextScaler.linear(5.0)),
                          Text(tab.name, textScaler: const TextScaler.linear(5.0)),
                          Text(tab.name, textScaler: const TextScaler.linear(5.0)),
                          
                        ],
                      ),
                    ),
                  ),
                );
              }
            ).toList()),
          )
        ]
      ),
    );
  }
  
}