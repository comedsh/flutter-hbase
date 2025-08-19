import 'package:appbase/appbase.dart';
import 'package:flutter/material.dart';
import 'package:hbase/hbase.dart';
import 'package:hbase/src/pages/nav_pages/me/views/me_subscr_info_view.dart';
import 'package:ionicons/ionicons.dart';
import 'package:sycomponents/components.dart';

class MePage extends StatelessWidget {
  final String? title;
  const MePage({super.key, this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title ?? '我的'),
      ),
      body: SingleChildScrollView(
        child: Column(children: [
            const MeSubscrInfoView(),
            CardListTiles(listTiles: [
              ListTile(
                leading: const Icon(Ionicons.heart_outline),
                title: Text('我的喜欢', style: TextStyle(fontSize: sp(18))),
                trailing: const Icon(Ionicons.chevron_forward_outline),
                onTap: () => {}
              ),
              ListTile(
                leading: const Icon(Ionicons.star_outline),
                title: Text('我的收藏', style: TextStyle(fontSize: sp(18))),
                trailing: const Icon(Ionicons.chevron_forward_outline),
                onTap: () => {}
              ),
              ListTile(
                leading: const Icon(Ionicons.bookmark_outline),
                title: Text('我的关注', style: TextStyle(fontSize: sp(18))),
                trailing: const Icon(Ionicons.chevron_forward_outline),
                onTap: () => Window.openWebView(title: '服务条款', url: '')
              ),
            ]),
            CardListTiles(listTiles: [
              ListTile(
                // leading: const Icon(Ionicons.trash_bin_outline),
                leading: const Icon(Icons.cleaning_services_outlined),
                title: Text('清空缓存', style: TextStyle(fontSize: sp(18))),
                trailing: const Icon(Ionicons.chevron_forward_outline),                
                onTap: () async {
                  // bool choice = await showConfirmDialog(context, content: '确定清除缓存？', confirmBtnTxt: '是', cancelBtnTxt: '否');
                  // if (choice) {
                  //   GlobalLoading.show();
                  //   await cachePurgeService.purge();
                  //   GlobalLoading.close();
                  //   if (context.mounted) {
                  //     await showAlertDialog(context, content: '已为您清除缓存 $size', confirmBtnTxt: '好的');
                  //     await doUpdate();
                  //   }
                  // }
                },
              ),
              ListTile(
                leading: const Icon(Icons.question_answer_outlined),
                title: Text('常见问答集锦', style: TextStyle(fontSize: sp(18))),
                trailing: const Icon(Ionicons.chevron_forward_outline),
                onTap: () {}
              ),
            ]),
            CardListTiles(listTiles: [
              ListTile(
                leading: const Icon(Icons.privacy_tip_outlined),
                title: Text('隐私政策', style: TextStyle(fontSize: sp(18))),
                trailing: const Icon(Ionicons.chevron_forward_outline),
                onTap: () => Window.openWebView(title:'隐私政策', url: '')
              ),
              ListTile(
                leading: const Icon(Icons.menu_outlined),
                title: Text('服务条款', style: TextStyle(fontSize: sp(18))),
                trailing: const Icon(Ionicons.chevron_forward_outline),
                onTap: () => Window.openWebView(title: '服务条款', url: '')
              ),
              ListTile(
                leading: const Icon(Ionicons.mail_outline),
                title: Text('联系我们', style: TextStyle(fontSize: sp(18))),
                trailing: const Icon(Ionicons.chevron_forward_outline),
                onTap: () => Window.openWebView(title: '联系我们', url: '')
              ),
            ]),
            CardListTiles(listTiles: [
              ListTile(
                leading: const Icon(Ionicons.log_out_outline),
                title: Text('退出登录', style: TextStyle(fontSize: sp(18))),
                trailing: const Icon(Ionicons.chevron_forward_outline),
                onTap: () => {}
              ),
              ListTile(
                leading: const Icon(Ionicons.close_circle_outline),
                title: Text('注销账号', style: TextStyle(fontSize: sp(18))),
                trailing: const Icon(Ionicons.chevron_forward_outline),
                onTap: () => {}
              ),
            ]),
            SizedBox(height: sp(20),),
            Center(child: Text('软件版本：${AppServiceManager.appConfig.version}')),
            SizedBox(height: sp(20),),
            const Center(child: Text('备案号：1234566')),
          ],
        ),
      ),
    );
  }
}