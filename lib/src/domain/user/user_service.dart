
import 'package:appbase/appbase.dart';
import 'package:hbase/hbase.dart';

class HBaseUserService {

  static follow(String profileCode) async {
    await dio.post('/u/follow/set', data: {
      'profileCode': profileCode
    });
  } 

  static disFollow(String profileCode) async {
    await dio.post('/u/follow/unset', data: {
      'profileCode': profileCode
    });
  }

  static favorite(String shortcode) async {
    await dio.post('/u/favorite/set', data: {
      'shortcode': shortcode
    });
  }

  static disFavorite(String shortcode) async {
    await dio.post('/u/favorite/unset', data: {
      'shortcode': shortcode
    });
  }

  static like(String shortcode) async {
    await dio.post('/u/like/set', data: {
      'shortcode': shortcode
    });
  }

  static disLike(String shortcode) async {
    await dio.post('/u/like/unset', data: {
      'shortcode': shortcode
    });
  }

  static HBaseUser get user => UserService.user as HBaseUser;

  /// 根据 [UserAuthority.unlockSubscrSale] 和 [UserAuthority.unlockPpointSale] 过滤出
  /// 可用的 saleGroups
  static List<SaleGroup> getAvailableSaleGroups() {
    var user = HBaseUserService.user;
    List<SaleGroup> saleGroups = [];
    for (var sg in AppServiceManager.appConfig.saleGroups) {
      if (sg.type == SaleGroupType.subscr || sg.type == SaleGroupType.noRenewalSubscr) {
        if (user.isUnlockSubscrSale) saleGroups.add(sg);
      }
      if (sg.type == SaleGroupType.points) {
        if (user.isUnlockPointSale) saleGroups.add(sg);
      }
    }
    return saleGroups;
  }
}