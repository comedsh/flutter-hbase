// ignore_for_file: depend_on_referenced_packages

import 'package:appbase/appbase.dart' hide UserService, Initializer;

import 'src/core/appconfig.dart';
import 'src/core/initializer.dart';
import 'src/core/response_handler.dart';
import 'src/domain/user/user_service.dart';
import 'src/pages/homepage.dart';

main() async {

  DemoInitializer initializer = DemoInitializer();
  ExampleUserService userService = ExampleUserService();
  DemoAppConfig appConfig = DemoAppConfig();
  DemoResponseHandler responseHandler = DemoResponseHandler();

  await Runner.run(
    initializer: initializer, 
    appConfig: appConfig,
    responseHandler: responseHandler,
    userService: userService,
    homePageCreator: (context) => const HomePage(),
  );
}
