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
  
  /// 直接查看打印的 DownloadStrategy 返回的内容即可，确保执行不会报错
  test('get download strategy', () async {
    await DownloadService.getDownloadStrategy(PostType.video);
    await DownloadService.getDownloadStrategy(PostType.album);
    await DownloadService.getDownloadStrategy(PostType.photo);
  });

}