import 'package:adjiang/src/pages/myspace/user_profile/user_profile_editor/user_profile_info_editor_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UserProfileEditorPage extends StatefulWidget {

  /// 参考 https://docs.flutter.dev/cookbook/forms/validation 实现 form submit
  const UserProfileEditorPage({super.key});

  @override
  State<UserProfileEditorPage> createState() => UserProfileEditorPageState();
}

class UserProfileEditorPageState extends State<UserProfileEditorPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('编辑我的信息'),
        // leading: Center(child: Text('取消', style: TextStyle(color: Colors.amber, fontSize: 16),)),
        leading: TextButton(
          onPressed: () => Get.back(), 
          child: Text('取消', style: TextStyle(
            color: Get.isDarkMode ? Colors.amber : Colors.amber.shade900, 
            fontSize: 16)
          )
        ),
        leadingWidth: 80,
      ),
      body: const Column(
        children: [
          UserProfileInfoEditorView()
        ],
      )
    );
  }
}