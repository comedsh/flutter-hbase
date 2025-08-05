
import 'package:appbase/appbase.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hbase/hbase.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sycomponents/components.dart';


void main() {
  setUp(() async {
    var dio = MockDio.mockDio(platformCode: 'beaut', sysCode: 'hyou1');
    setDio(dio);

    WidgetsFlutterBinding.ensureInitialized();
    /// 使用 mock SharedPerferences，否则在使用 SharedPreferences 的时候会报错：
    /// MissingPluginException(No implementation found for method getAll on channel plugins.flutter.io/shared_preferences)
    /// 因为测试环境没有设备以提供相应的 channels
    SharedPreferences.setMockInitialValues({});
    await SharedPreferences.getInstance();
  });  


  test('next ChannelPostGridPager', () async {
    var pager = ChannelPostGridPager(chnCodes: ['hanbeauti'], isReelOnly: true);
    List<Post> posts = await pager.nextPage();
    for(var post in posts) {
      debugPrint(post.toJson().toString());
    }
  });
}