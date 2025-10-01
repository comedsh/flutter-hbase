

// ignore_for_file: depend_on_referenced_packages

import 'package:hbase/hbase.dart';

class HQJGuanResponseHandler extends HBaseResponseHandler {
  
  @override
  void subIntercept(Map<String, dynamic> data) {
    /// impl your own intercept logic
    super.subIntercept(data);
  }

}