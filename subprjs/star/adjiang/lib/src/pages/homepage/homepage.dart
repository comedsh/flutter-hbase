import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:appbase/appbase.dart';
import 'package:hbase/hbase.dart';

import '../commons/pages/tab_bar_post_grid_list_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    var display = AppServiceManager.appConfig.display as HBaseDisplay;
    return TabBarPostGridListPage(
      chnCodes: display.chnCodes,
      tabs: display.tags.map<TabData>((tag) => TabData(id: tag.code, name: tag.name)).toList(),
      pageLabel: PageLabel.homePage,
    );
  }
}