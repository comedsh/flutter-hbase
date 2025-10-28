// ignore_for_file: depend_on_referenced_packages
import 'package:adjiang/src/pages/myspace/subscribe_info/subscribe_info_view.dart';
import 'package:flutter/material.dart';
import 'package:sycomponents/components.dart';
import 'package:get/get.dart';

import 'my_tool/my_tool_view.dart';
import 'point_info/point_info_view.dart';
import 'user_profile/user_profile_view.dart';

class MyspacePage extends StatefulWidget {
  static double get horizontalPaddingSize => sp(12.0);
  static double get verticalPaddingSize => sp(24.0);
  static double get verticalGapSize => sp(24);

  const MyspacePage({super.key});

  @override
  State<MyspacePage> createState() => _MyspacePageState();
}

class _MyspacePageState extends State<MyspacePage> {
  late bool dark;

  @override
  void initState() {
    dark = Get.isDarkMode;
    EventBus().on(EventConstants.themeChanged, themeChangedHandler);
    super.initState();
  }

  @override
  void dispose() {
    EventBus().off(EventConstants.themeChanged, themeChangedHandler);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: MyspacePage.horizontalPaddingSize, vertical: MyspacePage.verticalPaddingSize),
      decoration: !dark 
      ? BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[
              Colors.red.shade50,
              Colors.red.shade100,
              Colors.red.shade300,
              Colors.red.shade500
            ]
          ),
        )
      : null,  
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          const UserProfileView(),
          SizedBox(height: MyspacePage.verticalGapSize),
          const SubscribeInfoView(),
          // SizedBox(height: MyspacePage.verticalGapSize),
          // const PointInfoView(),
          SizedBox(height: MyspacePage.verticalGapSize),
          MyToolsView(isDark: dark,),
        ]
      )
    );
  }

  themeChangedHandler(isDark) => setState(() => dark = isDark);
}