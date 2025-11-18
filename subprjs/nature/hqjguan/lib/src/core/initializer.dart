// ignore_for_file: depend_on_referenced_packages

import 'package:appbase/appbase.dart';
import 'package:get/get.dart';
import 'package:hbase/hbase.dart';

class HQJGuanInitializer extends Initializer {

  HQJGuanInitializer._internal();

  static final HQJGuanInitializer _instance = HQJGuanInitializer._internal();

  factory HQJGuanInitializer() {
    return _instance;
  }

  @override
  initSubGetxServices() {
    Get.put(ScoreStateManager());
    Get.put(HBaseStateManager());
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