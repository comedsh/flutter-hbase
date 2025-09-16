import 'package:appbase/appbase.dart';
import 'package:hbase/hbase.dart';

class HBaseUser extends User {
  final List<UserAuthority> authorities;
  /// 每日下载剩余配额，仅用于条款展示，下载的时候是实时通过后台验证实现的。
  final int? dailyQuotaRemains;

  HBaseUser({
    required super.accessToken,
    required super.createTs,  
    super.subscr,
    super.point,
    required this.authorities,
    this.dailyQuotaRemains
  });

  HBaseUser.fromJson(super.json)
    : authorities = json['authorities'].map<UserAuthority>((auth) => UserAuthority.values.byName(auth)).toList(),
      dailyQuotaRemains = json['dailyQuotaRemains'],
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
  bool get isUnlockScoreSimple => authorities.contains(UserAuthority.unlockScoreSimple);
  bool get isUnlockScoreTarget => authorities.contains(UserAuthority.unlockScoreTarget);
  bool get isUnlockScoreToDownload => authorities.contains(UserAuthority.unlockScoreToDownload);
} 