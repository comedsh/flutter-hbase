import 'package:appbase/appbase.dart';
import 'package:hbase/hbase.dart';

class HBaseUser extends User {

  final List<UserAuthoriy> authorities;

  HBaseUser({
    required super.accessToken,
    required super.createTs,  
    super.subscr,
    super.point,
    required this.authorities
  });

  HBaseUser.fromJson(super.json)
    : authorities = json['authorities'].map<UserAuthoriy>((auth) => UserAuthoriy.values.byName(auth)).toList(),
      super.fromJson();

  @override
  Map<String, dynamic> toJson() => 
    {
      ...super.toJson(),
      'authorities': authorities.map<String>((auth) => auth.name).toList()
    };
  
  bool get isUnlockBlur => authorities.contains(UserAuthoriy.unlockBlur);
  bool get isUnlockPicDownload => authorities.contains(UserAuthoriy.unlockPicDownload);
  bool get isUnlockVideoDownload => authorities.contains(UserAuthoriy.unlockVideoDownload);
} 