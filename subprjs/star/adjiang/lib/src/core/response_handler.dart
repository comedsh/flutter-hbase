

// ignore_for_file: depend_on_referenced_packages
import 'package:adjiang/src/core/appconfig.dart';
import 'package:hbase/hbase.dart';
import 'package:appbase/appbase.dart';

class AdJiangResponseHandler extends HBaseResponseHandler {
  
  @override
  void subIntercept(Map<String, dynamic> data) {
    if (data['appConf'] != null) {
      var appConf = data['appConf'];
      AppServiceManager.appConfig.display = AdJiangDisplay.fromJson(appConf['display']);
    }
  }

}