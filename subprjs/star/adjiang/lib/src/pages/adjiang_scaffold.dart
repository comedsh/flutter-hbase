// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:sycomponents/components.dart';
import 'package:appbase/appbase.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';


class AdJiangScaffold extends StatelessWidget {
  final Widget child;
  const AdJiangScaffold({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('爱豆酱'),
        centerTitle: false,
        automaticallyImplyLeading: false,
        elevation: 4.0,
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
      body: child,
    );
  }
}