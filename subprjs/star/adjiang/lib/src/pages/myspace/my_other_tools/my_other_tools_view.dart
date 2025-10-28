// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:hbase/hbase.dart';
import 'package:ionicons/ionicons.dart';
import 'package:sycomponents/components.dart';
import 'package:get/get.dart';
import 'package:appbase/appbase.dart';

import '../constants.dart';

class MyOtherToolsView extends StatelessWidget {
  const MyOtherToolsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0.0, // Adds a shadow effect
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(MyspacePageConstants.cardBorderRadius), // Rounded corners
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            ListTile(
              dense: true,
              leading: const Icon(Icons.question_answer_outlined),
              title: Text('常见问答集锦', style: TextStyle(fontSize: sp(16))),
              trailing: const Icon(Ionicons.chevron_forward_outline),
              onTap: () => Get.to(() => const QuestionAnswerPage())
            ),
            ListTile(
              dense: true,
              leading: const Icon(Ionicons.heart_half_outline),
              title: Text('给我们打分', style: TextStyle(fontSize: sp(16))),
              trailing: const Icon(Ionicons.chevron_forward_outline),
              onTap: () => Rating.openStoreListing(AppServiceManager.appConfig.appStoreId)
            ),
            ListTile(
              leading: const Icon(Ionicons.eye_off_outline),
              title: Text('拉黑的用户', style: TextStyle(fontSize: sp(16))),
              trailing: const Icon(Ionicons.chevron_forward_outline),
              onTap: () => Get.to(() => const MeBlockedProfilesPage())
            ),
            ListTile(
              leading: const Icon(Ionicons.mail_outline),
              title: Text('联系我们', style: TextStyle(fontSize: sp(16))),
              trailing: const Icon(Ionicons.chevron_forward_outline),
              onTap: () => Window.openWebView(title: '联系我们', url: AppServiceManager.appConfig.docs.contactUsUrl)
            ),
            ListTile(
              leading: const Icon(Ionicons.settings_outline),
              title: Text('设置', style: TextStyle(fontSize: sp(16))),
              trailing: const Icon(Ionicons.chevron_forward_outline),
              onTap: () => Scaffold.of(context).openEndDrawer()
            ),            
          ]
        ),
      )
    );

  }
}