import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:sycomponents/components.dart';
// ignore: depend_on_referenced_packages
import 'package:appbase/appbase.dart';
import 'package:hbase/hbase.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';

import '../commons/pages/tab_bar_post_grid_list_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    var display = AppServiceManager.appConfig.display as HBaseDisplay;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('爱豆酱'),
        centerTitle: false,
        automaticallyImplyLeading: false,
        actions: [
          DarkModeSwitcher(
            scale: 0.8,
            isPersistence: true,
            isRespectDeviceTheme: false,
            isDefaultDarkMode: true,
            lightTheme: AppServiceManager.appConfig.appTheme.lightTheme,
            darkTheme: AppServiceManager.appConfig.appTheme.darkTheme
          ),
          IconButton(
            icon: const Icon(FeatherIcons.search), 
            onPressed: () {          
            }
          ),
          // 会员皇冠，如果已经是会员了则跳转到会员中心页
          IconButton(
            icon: Icon(
              IconFont.icon_sy_huangguan, 
              // color: const Color.fromARGB(255, 252, 189, 1),
              color: const Color.fromARGB(255, 252, 126, 1),
              size: sp(32)
            ),
            onPressed: () async {

            },
          )
        ],
      ),
      body: TabBarPostGridListPage(
        chnCodes: display.chnCodes,
        tabs: display.tags.map<TabData>((tag) => TabData(id: tag.code, name: tag.name)).toList(),
        pageLabel: PageLabel.homePage,
      ),
    );
  }
}