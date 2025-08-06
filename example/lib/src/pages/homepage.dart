
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hbase/hbase.dart';
import 'package:sycomponents/components.dart';

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
    return CategoryPage(tabs: [
      TabData(id: 'rcmd', name: '推荐'),
      TabData(id: 'omei', name: '欧美'),
      TabData(id: 'rihan', name: '日韩'),
      TabData(id: 'xmt', name: '新马泰'),
      TabData(id: 'qita', name: '其它'),
    ]);
  }
}