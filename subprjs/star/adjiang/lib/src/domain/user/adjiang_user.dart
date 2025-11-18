import 'package:hbase/hbase.dart';

class AdJiangUser extends HBaseUser {
  final String username;
  final String? avatarUrl;
  final String? gender;
  final DateTime? birthday;
  final String? signature;
  final int likeCount;
  final int favoriteCount;
  final int followCount;

  AdJiangUser.fromJson(super.json) 
    : username = json['username'],
      avatarUrl = json['avatarUrl'],
      gender = json['gender'],
      birthday = json['birthday'] != null ? DateTime.tryParse(json['birthday']) : null,
      signature = json['signature'],
      likeCount = json['likeCount'],
      favoriteCount = json['favoriteCount'],
      followCount = json['followCount'],
      super.fromJson();

  /// 注意，appbase 会 serialize user 存储到 local 中，然后启动的时候会先从 local 中 deserialize 并 parse，
  /// 但是如果缺少关键字段比如 [username] deserialize 的过程就会报错。因此为了应对这样的场景，toJson() 目前必须
  /// 实现，且也只需要填写关键字段即可；因为 app 能否使用还是必须在第一次 user hello 成功后才可以的。这就引发了我的
  /// 一个疑问了，既然非要联网获取 user 后才可以，为什么还要 serialize 到 local 然后再 deserialize？
  @override
  Map<String, dynamic> toJson() => 
    {
      ...super.toJson(),
      'username': username,
      'likeCount': likeCount,
      'favoriteCount': favoriteCount,
      'followCount': followCount
    };

}