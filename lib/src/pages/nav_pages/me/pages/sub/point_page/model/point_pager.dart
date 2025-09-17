
import 'package:appbase/appbase.dart';
import 'package:hbase/hbase.dart';

class PointReceiptPager extends Pager<PointReceipt> {

  PointReceiptPager({
    super.pageNum, 
    super.pageSize = 24, 
  });

  @override
  Future<List<PointReceipt>> fetchNextPage() async{
    var r = await dio.post('/u/point/receipt/page', data: {
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
    var r = await dio.post('/u/point/consumption/page', data: {
      "pageNum": pageNum,
      "pageSize": pageSize
    });
    var page = r.data['page'];
    return page.map<PointConsumption>((data) => PointConsumption.fromJson(data)).toList();
  }

}