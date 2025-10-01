import 'package:appbase/appbase.dart' hide UserService, Initializer;

import 'src/core/appconfig.dart';
import 'src/core/initializer.dart';
import 'src/core/response_handler.dart';
import 'src/domain/user/user_service.dart';
import 'src/pages/homepage.dart';

main() async {

  HQJGuanInitializer initializer = HQJGuanInitializer();
  HQJGuanUserService userService = HQJGuanUserService();
  HQJGuanAppConfig appConfig = HQJGuanAppConfig();
  HQJGuanResponseHandler responseHandler = HQJGuanResponseHandler();

  await Runner.run(
    initializer: initializer, 
    appConfig: appConfig,
    responseHandler: responseHandler,
    userService: userService,
    homePageCreator: (context) => const HomePage(),
  );
}
