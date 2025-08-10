import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hbase/hbase.dart';
import 'package:ionicons/ionicons.dart';

import 'category/category.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  
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
    return Scaffold(
      /// TODO configure the categories from backend and loaded to frontend
      body: CategoryPage(tabs: [
        TabData(id: 'rcmd', name: '推荐'),
        TabData(id: 'omei', name: '欧美'),
        TabData(id: 'rhan', name: '日韩'),
        TabData(id: 'xmt', name: '新马泰'),
        TabData(id: 'qita', name: '其它'),
      ]),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black54,
        // 如果超过 3 个 bar items 则必须添加
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            activeIcon: Icon(Ionicons.play_circle),
            icon: Icon(Ionicons.play_circle_outline),
            label: '视频',
          ),
          BottomNavigationBarItem(
            activeIcon: Icon(Ionicons.play_circle),
            icon: Icon(Ionicons.play_circle_outline),
            label: '视频',
          ),
          BottomNavigationBarItem(
            activeIcon: Icon(Ionicons.play_circle),
            icon: Icon(Ionicons.play_circle_outline),
            label: '视频',
          ),
          BottomNavigationBarItem(
            activeIcon: Icon(Ionicons.play_circle),
            icon: Icon(Ionicons.play_circle_outline),
            label: '视频',
          ),                              
        ]
      ),
    );
  }
}