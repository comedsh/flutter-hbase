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
            Padding(
              padding: EdgeInsets.symmetric(vertical: sp(6)),
              child: GradientElevatedButton(
                width: Screen.width(context) * 0.94,
                gradient: LinearGradient(colors: [
                  AppServiceManager.appConfig.appTheme.fillGradientStartColor, 
                  AppServiceManager.appConfig.appTheme.fillGradientEndColor
                ]),
                borderRadius: BorderRadius.circular(30.0),
                onPressed: () => Get.to(() => const PostSubmitPage()),
                child: Text(
                  '发布作品', 
                  style: TextStyle(
                    fontSize: sp(18), 
                    fontWeight: FontWeight.bold, 
                    // 强悍，使用下面这个方式设置颜色，就可以自动的感知 light/dark model 的变化了          
                    color: Theme.of(context).textTheme.bodyLarge?.color
                  )
                )
              ),
            ),
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
            /// 使用 Obx 监听用户状态的变化，然后更新界面展示
            Obx(() {
              if (HBaseUserService.user.point?.hasPurchasedPoint == true) {
                return CardListTiles(listTiles: [
                  ListTile(
                    leading: const Icon(Ionicons.server_outline),
                    title: Text('积分购买记录', style: TextStyle(fontSize: sp(18))),
                    trailing: const Icon(Ionicons.chevron_forward_outline),
                    onTap: () => Get.to(() => PointReceiptPage(pager: PointReceiptPager(),))
                  ),
                  ListTile(
                    leading: const Icon(IconFont.icon_sy_trade_record_2),
                    title: Text('积分消费记录', style: TextStyle(fontSize: sp(18))),
                    trailing: const Icon(Ionicons.chevron_forward_outline),
                    onTap: () => Get.to(() => PointConsumptionPage(pager: PointConsumptionPager(),))
                  ),
                ]);
              } else {
                return Container();
              }  
            }),
            CardListTiles(listTiles: [
              if ((AppServiceManager.appConfig.display as HBaseDisplay).showCleanCache == true) const ClearCacheListTile(),
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
            if ((AppServiceManager.appConfig.display as HBaseDisplay).showMeHomeScore)
              CardListTiles(listTiles: [
                ListTile(
                  leading: const Icon(Ionicons.heart_half_outline),
                  title: Text('给我们打分', style: TextStyle(fontSize: sp(18))),
                  trailing: const Icon(Ionicons.chevron_forward_outline),
                  onTap: () => Rating.openStoreListing(AppServiceManager.appConfig.appStoreId)
                ),
              ]),            
            CardListTiles(listTiles: [
              ListTile(
                leading: const Icon(Ionicons.log_out_outline),
                title: Text('退出登录', style: TextStyle(fontSize: sp(18))),
                trailing: const Icon(Ionicons.chevron_forward_outline),
                onTap: () async {
                  var isConfirmed = await showConfirmDialogWithoutContext(
                    title: '退出登录',
                    content: '退出登录后，您的喜欢、收藏、浏览和关注记录都会被删除，确定退出？',
                    confirmBtnTxt: '确定',
                    cancelBtnTxt: '不了'
                  );
                  if (isConfirmed) {
                    GlobalLoading.show();
                    try {
                      await dio.post('/u/logout');
                      GlobalLoading.close();
                      await showAlertDialogWithoutContext(
                        content: '已登出',
                        confirmBtnTxt: '好的'
                      );
                    } catch(e, stacktrace) {
                      debugPrint('user logout get error: $e, stacktrace: $stacktrace');
                      GlobalLoading.close();
                      showErrorToast(msg: '网络异常，请稍后再试');
                    }
                  }
                }
              ),
              ListTile(
                leading: const Icon(Ionicons.close_circle_outline),
                title: Text('注销账号', style: TextStyle(fontSize: sp(18))),
                trailing: const Icon(Ionicons.chevron_forward_outline),
                onTap: () async {
                  var isConfirmed = await showConfirmDialogWithoutContext(
                    title: '警告',
                    content: '注销账户后，您的订阅和其它交易记录都将会被清除，确定注销账户？',
                    confirmBtnTxt: '确定',
                    cancelBtnTxt: '不了'
                  );
                 if (isConfirmed) {
                    GlobalLoading.show();
                    try {
                      await dio.post('/u/zhuxiao');
                      GlobalLoading.close();
                      await showAlertDialogWithoutContext(
                        content: '账户已注销',
                        confirmBtnTxt: '好的'
                      );
                      // 只在前端清空用户的订阅、积分等信息          
                      var userStateMgr = Get.find<UserStateManager>();
                      var user = userStateMgr.user; 
                      user.update((user) {
                        user!.subscr = null;
                        user.point = Point(hasPurchasedPoint: false, remainPoints: 0);
                      });                                       
                    } catch(e, stacktrace) {
                      debugPrint('user logout get error: $e, stacktrace: $stacktrace');
                      GlobalLoading.close();
                      showErrorToast(msg: '网络异常，请稍后再试');
                    }
                  }
                }
              ),
            ]),
            SizedBox(height: sp(20),),
            Center(child: Obx(() => Text('软件版本：${version.toString()}'))),
            SizedBox(height: sp(20),),
            if ((AppServiceManager.appConfig.display as HBaseDisplay).showBeianNum) 
              Center(child: Text(AppServiceManager.appConfig.beianNum)),
            SizedBox(height: sp(20),),
          ],
        ),
      ),
    );
  }
}