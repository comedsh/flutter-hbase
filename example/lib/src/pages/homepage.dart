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
    return Scaffold(
      body: ProsteIndexedStack(
        index: _current,
        children: [
          IndexedStackChild(
            child: CategoryPostFullScreenListViewPage(tabs: [
              TabData(id: 'rcmd', name: '推荐'),
              TabData(id: 'omei', name: '欧美'),
              TabData(id: 'rhan', name: '日韩'),
              TabData(id: 'xmt', name: '新马泰'),
              TabData(id: 'qita', name: '其它'),
            ]),
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
            child: Scaffold(
              appBar: AppBar(title: const Text('我')),
              body: const Center(
                child: Text('我 Demo Page', 
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),)),
            )
          ),          
        ]
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black54,
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