// ignore_for_file: depend_on_referenced_packages

import 'package:appbase/appbase.dart';
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