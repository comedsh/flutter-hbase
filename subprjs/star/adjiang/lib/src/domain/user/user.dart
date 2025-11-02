import 'package:hbase/hbase.dart';

class AdJiangUser extends HBaseUser {
  final String username;
  final String? gender;
  final DateTime? birthday;
  final String? signature;
  final int likeCount;
  final int favoriteCount;
  final int followCount;

  AdJiangUser.fromJson(super.json) 
    : username = json['username'],
      gender = json['gender'],
      birthday = json['birthday'] != null ? DateTime.tryParse(json['birthday']) : null,
      signature = json['signature'],
      likeCount = json['likeCount'],
      favoriteCount = json['favoriteCount'],
      followCount = json['followCount'],
      super.fromJson();

}