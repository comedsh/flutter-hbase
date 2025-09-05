

import 'package:appbase/appbase.dart';
import 'package:hbase/src/core/hbase_appconfig.dart';

class HBaseResponseHandler extends ResponseHandler {
  
  @override
  void subIntercept(Map<String, dynamic> data) {
    if (data['appConf'] != null) {
      var appConf = data['appConf'];
      (AppServiceManager.appConfig as HBaseAppConfig).showJubao = appConf['showJubao'];
    }
  }

}