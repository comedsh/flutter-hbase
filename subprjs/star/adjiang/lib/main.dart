// ignore: depend_on_referenced_packages
import 'package:appbase/appbase.dart' hide UserService, Initializer;

import 'src/core/adjiang_appconfig.dart';
import 'src/core/adjiang_initializer.dart';
import 'src/core/adjiang_response_handler.dart';
import 'src/domain/user/adjiang_user_service.dart';
import 'src/pages/skeleton.dart';

main() async {

  AdJiangInitializer initializer = AdJiangInitializer();
  AdJiangUserService userService = AdJiangUserService();
  AdJiangAppConfig appConfig = AdJiangAppConfig();
  AdJiangResponseHandler responseHandler = AdJiangResponseHandler();


  /// 注入：爱豆酱的入口执行，[initializer] 提供入口选项的参数，[appConfig] 提供应用的配置项
  /// [responseHandler] 提供响应解析入口
  await Runner.run(
    initializer: initializer, 
    appConfig: appConfig,
    responseHandler: responseHandler,
    userService: userService,
    homePageCreator: (context) => const AdJiangSkeleton(),
  );
}
