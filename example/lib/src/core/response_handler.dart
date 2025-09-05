

import 'package:hbase/hbase.dart';

class DemoResponseHandler extends HBaseResponseHandler {
  
  @override
  void subIntercept(Map<String, dynamic> data) {
    /// impl your own intercept logic
    super.subIntercept(data);
  }

}