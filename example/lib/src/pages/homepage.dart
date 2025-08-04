
import 'dart:async';

import 'package:appbase/appbase.dart' hide User;
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:sycomponents/components.dart';
import 'package:sypayment/sypayment.dart';

import '../domain/user/user.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  late StreamSubscription<List<ConnectivityResult>> subscription;
  var userStateMgr = Get.find<UserStateManager>();
  var localTimezone = ''.obs;


  @override
  void initState() {
    super.initState();
    
  }

  doInit() async {
    localTimezone.value = await FlutterTimezone.getLocalTimezone();
  }

  @override
  void dispose() {
    debugPrint('$HomePage dispose calls');
    subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("appbase"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  '屏幕基准尺寸：',
                ),
                Text(
                  'Width: ${Screen.width(context)}, Height: ${Screen.height(context)}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),                
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  '配置的域名是：',
                ),
                Text(
                  EnvConfig.baseUrl,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),                
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  '登录状态：',
                ),
                Obx(() => Text(
                  userStateMgr.isSignedIn == false ? '未登录': '已登录',
                  style: Theme.of(context).textTheme.bodyMedium,
                )),                  
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  '订阅状态：',
                ),
                SizedBox(
                  width: 280,
                  child: Obx(() => Text(
                    userStateMgr.isSignedIn == false
                      ? '未同步'
                      : userStateMgr.user.value.subscr != null 
                        // 使用 user() 可以替代 user.value 的写法
                        ? '${userStateMgr.user().subscr?.toJson()}'
                        : '未订阅',
                    softWrap: true,
                    style: Theme.of(context).textTheme.bodySmall,
                  )),
                ),                  
              ],
            ),           
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  '用户详情：',
                ),
                SizedBox(
                  width: 280,
                  /// 太牛了，Obx 可以直接监听 user 对象的变化；
                  child: Obx(() => Text(
                    "${userStateMgr.user().toJson()}",
                    softWrap: true,
                    style: Theme.of(context).textTheme.bodySmall,
                  )),
                ),                  
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'TimeZone Way 1：',
                ),
                Text(
                  'zonename: ${DateTime.now().timeZoneName}, offset: ${DateTime.now().timeZoneOffset}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),                  
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'TimeZone Way 2：',
                ),
                Obx(() => Text(
                  'zonename: $localTimezone',
                  style: Theme.of(context).textTheme.bodySmall,
                )),                  
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(onPressed: () {
                  var subscr = Subscription(title: '月会员', start: DateTime.now(), end: DateTime.now(), isValid: true);
                  var userStateMgr = Get.find<UserStateManager>();
                  var user = userStateMgr.user; 
                  user.update((user) {
                    user!.subscr = subscr;
                  });                 
                }, child: Text('mock a valid subscription', style: Theme.of(context).textTheme.bodyMedium),)
              ]
            ),
            const SizedBox(height: 20),
            /// 该测试用例描述了可以通过子类 [DemoUser] 来扩展 userStateManager 中被监控的 [User] 对象
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(onPressed: () {
                  var userStateMgr = Get.find<UserStateManager>();
                  var user = userStateMgr.user; 
                  /// 使用 [UserStateManager.refresh] 方法更新整个 user 也是可以的，参考 [ResponseHandler.parseUser] 中
                  /// 的 UserService.syncUserState 执行逻辑
                  user.update((user) {
                    /// 这里是关键扩展点，将 user 映射为子系统的 User，这样就可以对它进行响应式编程了
                    var localUser = user! as DemoUser;
                    localUser.username = 'shangyang';
                    localUser.email = 'shangyang@gmail.com';
                  });                 
                }, child: Text('change username and email', style: Theme.of(context).textTheme.bodyMedium),)
              ]
            ),            
            const SizedBox(height: 20),
            Wrap(
              children: [
                ElevatedButton(onPressed: () {
                  Get.to(() => SalePage(saleGroups: AppServiceManager.appConfig.saleGroups,));
                }, child: Text('进入普通订阅页面', style: Theme.of(context).textTheme.bodyMedium),),
                const SizedBox(width: 20,),
                ElevatedButton(onPressed: () {
                  Get.to(() => SalePage(saleGroups: AppServiceManager.appConfig.saleGroups, initialSaleGroupId: 'advancedSubscr',));
                }, child: Text('进入高级订阅页面', style: Theme.of(context).textTheme.bodyMedium),),
                const SizedBox(width: 20,),
                ElevatedButton(onPressed: () {
                  Get.to(() => SalePage(saleGroups: AppServiceManager.appConfig.saleGroups, initialSaleGroupId: 'noRenewalSubscr',));
                }, child: Text('进入非续期订阅', style: Theme.of(context).textTheme.bodyMedium),),
                const SizedBox(width: 20,),
                ElevatedButton(onPressed: () {
                  Get.to(() => SalePage(saleGroups: AppServiceManager.appConfig.saleGroups, initialSaleGroupId: 'points',));
                }, child: Text('进入积分购买页面', style: Theme.of(context).textTheme.bodyMedium),)
              ]
            ),
            const SizedBox(height: 20),
            Wrap(
              children: [
                ElevatedButton(onPressed: () async {
                  const iapProductId = "DEMO_0006";
                  var pd = await PaymentParser.parseSingle(iapProductId);
                  if (pd == null) {
                    showErrorToast(msg: '支付环境异常，请检查您的网络！');
                  } else {
                    var shortcode = 'XYZABCDEFG002';
                    ExtraTradeParam param = ExtraTradeParam(productId: iapProductId, action: 'download', resourceId: shortcode);
                    await ManualPaymentHandler().buy(pd,
                      tradeParam: param,
                      successCallback: () async {
                        await showAlertDialogWithoutContext(title: '交易成功', content: "立刻开启下载资源$shortcode");
                      },
                      failCallback: () async {
                        await showAlertDialogWithoutContext(title: '交易失败', content: "交易失败");
                      }
                    );
                  }                  
                }, child: Text('单次付费下载', style: Theme.of(context).textTheme.bodyMedium),),
              ],
            )
          ],
        ),
      ),
    );
  }
}