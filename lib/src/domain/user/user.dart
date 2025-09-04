import 'package:appbase/appbase.dart';
import 'package:hbase/hbase.dart';

class HBaseUser extends User {

  final List<UserAuthority> authorities;

  HBaseUser({
    required super.accessToken,
    required super.createTs,  
    super.subscr,
    super.point,
    required this.authorities
  });

  HBaseUser.fromJson(super.json)
    : authorities = json['authorities'].map<UserAuthority>((auth) => UserAuthority.values.byName(auth)).toList(),
      super.fromJson();

  @override
  Map<String, dynamic> toJson() => 
    {
      ...super.toJson(),
      'authorities': authorities.map<String>((auth) => auth.name).toList()
    };
  
  bool get isUnlockBlur => authorities.contains(UserAuthority.unlockBlur);
  bool get isUnlockPicDownload => authorities.contains(UserAuthority.unlockPicDownload);
  bool get isUnlockVideoDownload => authorities.contains(UserAuthority.unlockVideoDownload);
  bool get isUnlockSubscrSale => authorities.contains(UserAuthority.unlockSubscrSale);
  bool get isUnlockPointSale => authorities.contains(UserAuthority.unlockPointSale);
  bool get isUnlockTranslation => authorities.contains(UserAuthority.unlockTranslation);
} 