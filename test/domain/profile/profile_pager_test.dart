
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


  test('next HotestPerTagsProfileGroupPager', () async {
    var chnCodes = ['hanbeauti', 'art'];
    var tagCodes = ['omei', 'rhan', 'xmt', 'twan', 'dalu'];
    var pager = HotestPerTagsProfileGroupPager(chnCodes: chnCodes, tagCodes: tagCodes);
    List<List<Profile>> profileGroup = await pager.nextPage();
    for (var i = 0; i < tagCodes.length; i++) {
      var tagCode = tagCodes[i];
      debugPrint("--------------------------");
      debugPrint("--------------------------");
      debugPrint("$tagCode =====================================");
      List<Profile> profiles = profileGroup[i];
      for (var profile in profiles) {
        debugPrint("${profile.code}, ${profile.name}, ${profile.followerCount}");
      }
    }
  });

  test('next HotestProfilePager', () async {
    /// CASE I 只有 chnCodes
    List<String>? chnCodes = ['hanbeauti', 'art'];
    var pager = HotestProfilePager(chnCodes: chnCodes);
    List<Profile> profiles = await pager.nextPage();
    for (var profile in profiles) {
      debugPrint("${profile.code}, ${profile.name}, ${profile.followerCount}");
    }
    debugPrint("--------------------------");
    debugPrint("--------------------------");

    /// CASE II 只有 tagCodes
    List<String>? tagCodes = ['omei', 'rhan', 'xmt', 'twan', 'dalu'];
    pager = HotestProfilePager(tagCodes: tagCodes);
    profiles = await pager.nextPage();
    for (var profile in profiles) {
      debugPrint("${profile.code}, ${profile.name}, ${profile.followerCount}");
    }
    debugPrint("--------------------------");
    debugPrint("--------------------------");
    
    /// CASE III 有 chnCodes 但只有一个 tagCode
    pager = HotestProfilePager(chnCodes: chnCodes, tagCodes: ['omei']);
    profiles = await pager.nextPage();
    for (var profile in profiles) {
      debugPrint("${profile.code}, ${profile.name}, ${profile.followerCount}");
    }
    debugPrint("--------------------------");
    debugPrint("--------------------------");

    /// CASE IV 只有一个 chnCode 和一个 tagCode
    pager = HotestProfilePager(chnCodes: ['hanbeauti'], tagCodes: ['rhan']);
    profiles = await pager.nextPage();
    for (var profile in profiles) {
      debugPrint("${profile.code}, ${profile.name}, ${profile.followerCount}");
    }    
  });

}