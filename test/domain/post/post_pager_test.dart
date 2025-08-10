
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


  test('next ChannelPostPager', () async {
    var pager = ChannelTagPostPager(chnCodes: ['hanbeauti'], isReelOnly: true);
    List<Post> posts = await pager.nextPage();
    for(var post in posts) {
      debugPrint(post.toJson().toString());
    }
    debugPrint('===========================================================');
    pager = ChannelTagPostPager(chnCodes: ['hanbeauti', 'star'], tagCodes: ['omei'], isReelOnly: true);
    posts = await pager.nextPage();
    for(var post in posts) {
      debugPrint(post.toJson().toString());
    }
  });

  test('next ProfilePostPager', () async {
    var pager = ProfilePostPager(profileCode: 'johnalaska', sortBy: 'new');
    List<Post> posts = await pager.nextPage();
    // ignore: avoid_function_literals_in_foreach_calls
    posts.forEach((p) => debugPrint('${p.shortcode}, ${p.profileCode}, ${p.uploadTs}'));
    posts = await pager.nextPage();
    // ignore: avoid_function_literals_in_foreach_calls
    posts.forEach((p) => debugPrint('${p.shortcode}, ${p.profileCode}, ${p.uploadTs}'));
    debugPrint('===========================================================');
    pager = ProfilePostPager(profileCode: 'johnalaska', sortBy: 'hot');
    posts = await pager.nextPage();
    // ignore: avoid_function_literals_in_foreach_calls
    posts.forEach((p) => debugPrint('${p.shortcode}, ${p.profileCode}, ${p.uploadTs}'));
    posts = await pager.nextPage();
    // ignore: avoid_function_literals_in_foreach_calls
    posts.forEach((p) => debugPrint('${p.shortcode}, ${p.profileCode}, ${p.uploadTs}'));
  });
}