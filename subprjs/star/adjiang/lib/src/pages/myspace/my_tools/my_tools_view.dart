// ignore_for_file: depend_on_referenced_packages

import 'package:adjiang/src/pages/myspace/constants.dart';
import 'package:adjiang/src/pages/myspace/my_tools/my_tool_icon_button.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';

class MyToolsView extends StatelessWidget {
  final bool isDark;
  const MyToolsView({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0.0, // Adds a shadow effect
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(MyspacePageConstants.cardBorderRadius), // Rounded corners
      ),
      child: Padding(
        padding: EdgeInsets.all(MyspacePageConstants.cardPaddingSize),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                MyToolIconButton(
                  iconData: Ionicons.bookmark_outline, 
                  iconLightModeColor: Colors.blue.shade900, 
                  text: '我的关注', 
                  isDark: isDark,
                ),
                MyToolIconButton(
                  iconData: Ionicons.heart_outline, 
                  iconLightModeColor: Colors.red.shade700, 
                  text: '我的喜欢', 
                  isDark: isDark,
                ),
                MyToolIconButton(
                  iconData: Ionicons.star_outline, 
                  iconLightModeColor: Colors.amber.shade900, 
                  text: '我的收藏', 
                  isDark: isDark,
                ),
                MyToolIconButton(
                  iconData: Ionicons.time_outline,
                  text: '浏览记录', 
                  isDark: isDark,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}