import 'package:appbase/appbase.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hbase/hbase.dart';
import 'package:hbase/src/pages/nav_pages/me/views/me_subscr_info_view.dart';
import 'package:hbase/src/pages/nav_pages/me/widgets/clear_cache_list_tile.dart';
import 'package:ionicons/ionicons.dart';
import 'package:sycomponents/components.dart';

class MePage extends StatefulWidget {
  final String? title;
  const MePage({super.key, this.title});

  @override
  State<MePage> createState() => _MePageState();
}

class _MePageState extends State<MePage> {

  final version = ''.obs;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      version.value = await AppServiceManager.appConfig.version;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? '我的'),
      ),
      body: SingleChildScrollView(
        child: Column(children: [
            const MeSubscrInfoView(),
            CardListTiles(listTiles: [
              ListTile(
                leading: const Icon(Ionicons.heart_outline),
                title: Text('我的喜欢', style: TextStyle(fontSize: sp(18))),
                trailing: const Icon(Ionicons.chevron_forward_outline),
                onTap: () => Get.to(() => const MeLikePage())
              ),
              ListTile(
                leading: const Icon(Ionicons.star_outline),
                title: Text('我的收藏', style: TextStyle(fontSize: sp(18))),
                trailing: const Icon(Ionicons.chevron_forward_outline),
                onTap: () => Get.to(() => const MeFavoritePage())
              ),
              ListTile(
                leading: const Icon(Ionicons.bookmark_outline),
                title: Text('我的关注', style: TextStyle(fontSize: sp(18))),
                trailing: const Icon(Ionicons.chevron_forward_outline),
                onTap: () => Get.to(() => const MeFollowPage())
              ),
              ListTile(
                leading: const Icon(Ionicons.time_outline),
                title: Text('我的浏览记录', style: TextStyle(fontSize: sp(18))),
                trailing: const Icon(Ionicons.chevron_forward_outline),
                onTap: () => Get.to(() => const MeViewhisPage())
              ),              
            ]),
            /// TODO 购买积分后才展示
            CardListTiles(listTiles: [
              ListTile(
                leading: const Icon(Ionicons.server_outline),
                title: Text('积分购买记录', style: TextStyle(fontSize: sp(18))),
                trailing: const Icon(Ionicons.chevron_forward_outline),
                onTap: () => Get.to(() => const QuestionAnswerPage())
              ),
              ListTile(
                leading: const Icon(IconFont.icon_sy_trade_record_2),
                title: Text('积分消费记录', style: TextStyle(fontSize: sp(18))),
                trailing: const Icon(Ionicons.chevron_forward_outline),
                onTap: () => Get.to(() => const QuestionAnswerPage())
              ),
            ]),
            CardListTiles(listTiles: [
              if ((AppServiceManager.appConfig as HBaseAppConfig).showCleanCache == true) const ClearCacheListTile(),
              ListTile(
                leading: const Icon(Icons.question_answer_outlined),
                title: Text('常见问答集锦', style: TextStyle(fontSize: sp(18))),
                trailing: const Icon(Ionicons.chevron_forward_outline),
                onTap: () => Get.to(() => const QuestionAnswerPage())
              ),
            ]),
            CardListTiles(listTiles: [
              ListTile(
                leading: const Icon(Icons.privacy_tip_outlined),
                title: Text('隐私政策', style: TextStyle(fontSize: sp(18))),
                trailing: const Icon(Ionicons.chevron_forward_outline),
                onTap: () => Window.openWebView(title:'隐私政策', url: AppServiceManager.appConfig.docs.yinSiXieYiUrl)
              ),
              ListTile(
                leading: const Icon(Icons.menu_outlined),
                title: Text('服务条款', style: TextStyle(fontSize: sp(18))),
                trailing: const Icon(Ionicons.chevron_forward_outline),
                onTap: () => Window.openWebView(title: '服务条款', url: AppServiceManager.appConfig.docs.fuWuXieYiUrl)
              ),
              ListTile(
                leading: const Icon(Ionicons.mail_outline),
                title: Text('联系我们', style: TextStyle(fontSize: sp(18))),
                trailing: const Icon(Ionicons.chevron_forward_outline),
                onTap: () => Window.openWebView(title: '联系我们', url: AppServiceManager.appConfig.docs.contactUsUrl)
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
            Center(child: Obx(() => Text('软件版本：${version.toString()}'))),
            SizedBox(height: sp(20),),
            if ((AppServiceManager.appConfig as HBaseAppConfig).showBeianNum) 
              Center(child: Text(AppServiceManager.appConfig.beianNum)),
            SizedBox(height: sp(20),),
          ],
        ),
      ),
    );
  }
}