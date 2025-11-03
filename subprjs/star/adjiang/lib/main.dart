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

  await Runner.run(
    initializer: initializer, 
    appConfig: appConfig,
    responseHandler: responseHandler,
    userService: userService,
    homePageCreator: (context) => const Skeleton(),
  );
}
