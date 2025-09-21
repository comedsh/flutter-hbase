import 'package:appbase/appbase.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hbase/hbase.dart';

class DemoInitializer extends Initializer {

  DemoInitializer._internal();

  static final DemoInitializer _instance = DemoInitializer._internal();

  factory DemoInitializer() {
    return _instance;
  }

  @override
  initSubGetxServices() {
    Get.put(ScoreStateManager());
  }
  
  @override
  initSubBeforeConnected() async {
    /// 模拟注册行为，添加 username 和 email；为什么是在 user signed in 之后追加呢？是因为对于新用户 hello 阶段
    /// 就只应该创建 base user info 信息，而其他额外的信息是通过请他业务请求追加的；      
    // var usm = Get.find<UserStateManager>();
    // once(usm.signedInState, (s) async {
    //   debugPrint('demo caught user signed in state change');
    //   final random = Random();
    //   const usernames = ['Johnson', 'Kelison', 'Jimmy'];
    //   const emails = ['test1@test.com', 'test2@test.com', 'test3@test.com'];
    //   await Future<void>.delayed(const Duration(seconds: 2));
    //   /// 模拟注册行为，添加 username 和 email
    //   await dio.post('/u/update', data: {
    //     'username': usernames[random.nextInt(usernames.length)],  // 随机选择一个 username 
    //     'email': emails[random.nextInt(emails.length)]
    //   });
    // });
    
    Get.changeTheme(AppServiceManager.appConfig.appTheme.darkTheme);
  }

  @override
  initSubAfterConnected() async {       
  }
  
  @override
  initAfterSynced() async {
    ScoreService.listen();
  }

}