
// ignore_for_file: depend_on_referenced_packages

import 'package:appbase/appbase.dart';
import 'package:hbase/hbase.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class PointReceiptPager extends Pager<PointReceipt> {

  PointReceiptPager({
    super.pageNum, 
    super.pageSize = 24, 
  });

  @override
  Future<List<PointReceipt>> fetchNextPage() async{
    /// API_POST_USER_POINT_RECEIPT_PAGE -> /u/point/receipt/page
    var r = await dio.post(dotenv.env['API_POST_USER_POINT_RECEIPT_PAGE']!, data: {
      "pageNum": pageNum,
      "pageSize": pageSize
    });
    var page = r.data['page'];
    return page.map<PointReceipt>((data) => PointReceipt.fromJson(data)).toList();
  }

}

class PointConsumptionPager extends Pager<PointConsumption> {

  @override
  Future<List<PointConsumption>> fetchNextPage() async {
    /// API_POST_USER_POINT_CONSUMPTION_PAGE -> /u/point/consumption/page
    var r = await dio.post(dotenv.env['API_POST_USER_POINT_CONSUMPTION_PAGE']!, data: {
      "pageNum": pageNum,
      "pageSize": pageSize
    });
    var page = r.data['page'];
    return page.map<PointConsumption>((data) => PointConsumption.fromJson(data)).toList();
  }

}