

// ignore_for_file: depend_on_referenced_packages
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:appbase/appbase.dart';
import 'package:flutter/material.dart';
import 'package:hbase/hbase.dart';

class HotestPerTagsProfileGroupPager extends Pager<List<Profile>> {
  final List<String> chnCodes;
  final List<String> tagCodes;

  HotestPerTagsProfileGroupPager({super.pageNum, super.pageSize, required this.chnCodes, required this.tagCodes});


  /// 返回的是 ProfileGroup，里面是根据每个 tagCode 一个 Profile List 的这样一个数据结构；
  @override
  Future<List<List<Profile>>> fetchNextPage() async {
    var chnCodesStr = chnCodes.join(',');
    var tagCodesStr = tagCodes.join(',');

    // API_GET_PROFILE_HOT_PERTAGS_PREFIX -> /profile/hot/pertags
    var r = await dio.get('${dotenv.env['API_GET_PROFILE_HOT_PERTAGS_PREFIX']}/$pageNum/$pageSize/$chnCodesStr/$tagCodesStr');
    var profileGroupData = r.data;
    List<List<Profile>> profileGroup = [];
    for (var rawProfiles in profileGroupData) {
      profileGroup.add(rawProfiles.map<Profile>((data) { 
        debugPrint('try parse profile ${data['code']}');
        return Profile.fromJson(data); 
      }).toList());
    }
    return profileGroup;
  }

}

/// 这个没有必要，因为它就是 [HotestProfilePager] 的一个特列
@Deprecated('没有必要，因为它就是 [HotestProfilePager] 的一个特列')
class HotestProfilePagerPerTag extends Pager<Profile> {
  final List<String> chnCodes;
  final String tagCode;

  HotestProfilePagerPerTag({super.pageNum, super.pageSize, required this.chnCodes, required this.tagCode});

  @override
  Future<List<Profile>> fetchNextPage() {
    // TODO: implement fetchNextPage
    throw UnimplementedError();
  }

}

class HotestProfilePager extends Pager<Profile> {
  final List<String>? chnCodes;
  final List<String>? tagCodes;

  HotestProfilePager({super.pageNum, super.pageSize, this.chnCodes, this.tagCodes});

  @override
  Future<List<Profile>> fetchNextPage() async {
    var chnCodesStr = chnCodes?.join(',');
    var tagCodesStr = tagCodes?.join(',');
    // API_GET_PROFILE_HOT_PREFIX -> /profile/hot
    var r = await dio.get('${dotenv.env['API_GET_PROFILE_HOT_PREFIX']}/$pageNum/$pageSize/$chnCodesStr/$tagCodesStr');
    return r.data.map<Profile>((data) => Profile.fromJson(data)).toList();
  }

}

class SearchProfilePager extends Pager<Profile> {
  final String token;
  final List<String>? chnCodes;

  SearchProfilePager({
    super.pageNum,
    super.pageSize,
    required this.token,
    this.chnCodes
  });

  @override
  Future<List<Profile>> fetchNextPage() async {
    var r = await dio.post('/search/profiles', data: {
      'pageNum': pageNum,
      'pageSize': pageSize,
      'token': token,
      'chnCodes': chnCodes
    });
    return r.data.map<Profile>((data) => Profile.fromJson(data)).toList();
  }

}