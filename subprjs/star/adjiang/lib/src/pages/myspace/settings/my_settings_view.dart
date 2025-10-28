import 'package:flutter/material.dart';
import 'package:hbase/hbase.dart';
import 'package:ionicons/ionicons.dart';
import 'package:get/get.dart';
import 'package:appbase/appbase.dart';
import 'package:hbase/hbase.dart';
import 'package:sycomponents/components.dart';


class MySettingsView extends StatelessWidget {
  const MySettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: Screen.width(context) * 0.8,
      backgroundColor: Theme.of(context).cardColor,
      child: Padding(
        padding: EdgeInsets.only(top: sp(80), left: sp(8), right: sp(8)),
        child: Column(
          children: [
            Card(
              elevation: 0,
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.privacy_tip_outlined),
                    title: Text('隐私政策', style: TextStyle(fontSize: sp(16))),
                    trailing: const Icon(Ionicons.chevron_forward_outline),
                    onTap: () => Window.openWebView(title:'隐私政策', url: AppServiceManager.appConfig.docs.yinSiXieYiUrl)
                  ),
                  ListTile(
                    leading: const Icon(Icons.menu_outlined),
                    title: Text('服务条款', style: TextStyle(fontSize: sp(16))),
                    trailing: const Icon(Ionicons.chevron_forward_outline),
                    onTap: () => Window.openWebView(title: '服务条款', url: AppServiceManager.appConfig.docs.fuWuXieYiUrl)
                  ),
                  
                ],
              ),
            ),
            SizedBox(height: sp(16)),
            Card(
              elevation: 0,
              child: Column(
                children: [
                  ClearCacheListTile(fontSize: sp(16))
                ],
              )
            ),
            SizedBox(height: sp(16)),
            Card(
              elevation: 0,
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Ionicons.close_circle_outline),
                    title: Text('注销账号', style: TextStyle(fontSize: sp(16))),
                    trailing: const Icon(Ionicons.chevron_forward_outline),
                    onTap: () async => PageService.zhuxiao()
                  ),
                ],
              )
            )
          ],        
        ),
      )
    );
  }
}