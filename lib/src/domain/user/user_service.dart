
// ignore_for_file: depend_on_referenced_packages

import 'package:appbase/appbase.dart';
import 'package:hbase/hbase.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class HBaseUserService {

  static follow(String profileCode) async {
    /// API_POST_USER_FOLLOW_SET -> /u/follow/set
    await dio.post(dotenv.env['API_POST_USER_FOLLOW_SET']!, data: {
      'profileCode': profileCode
    });
  } 

  static disFollow(String profileCode) async {
    /// API_POST_USER_FOLLOW_UNSET -> /u/follow/unset
    await dio.post(dotenv.env['API_POST_USER_FOLLOW_UNSET']!, data: {
      'profileCode': profileCode
    });
  }

  static favorite(String shortcode) async {
    /// API_POST_USER_FAVORITE_SET -> /u/favorite/set
    await dio.post(dotenv.env['API_POST_USER_FAVORITE_SET']!, data: {
      'shortcode': shortcode
    });
  }

  static disFavorite(String shortcode) async {
    /// API_POST_USER_FAVORITE_UNSET -> /u/favorite/unset
    await dio.post(dotenv.env['API_POST_USER_FAVORITE_UNSET']!, data: {
      'shortcode': shortcode
    });
  }

  static like(String shortcode) async {
    /// API_POST_USER_LIKE_SET -> /u/like/set
    await dio.post(dotenv.env['API_POST_USER_LIKE_SET']!, data: {
      'shortcode': shortcode
    });
  }

  static disLike(String shortcode) async {
    /// API_POST_USER_LIKE_UNSET -> /u/like/unset
    await dio.post(dotenv.env['API_POST_USER_LIKE_UNSET']!, data: {
      'shortcode': shortcode
    });
  }

  static saveViewHis(String shortcode) async {
    /// API_POST_USER_VIEWHIS -> /u/viewhis
    await dio.post(dotenv.env['API_POST_USER_VIEWHIS']!, data: {
      'shortcode': shortcode        
    }); 
  }

  static HBaseUser get user => UserService.user as HBaseUser;

  /// 根据 [UserAuthority.unlockSubscrSale] 和 [UserAuthority.unlockPointSale] 过滤出
  /// 可用的 saleGroups
  // @Deprecated('已经从后台进行过滤了')
  // static List<SaleGroup> getAvailableSaleGroups() {
  //   var user = HBaseUserService.user;
  //   List<SaleGroup> saleGroups = [];
  //   for (var sg in AppServiceManager.appConfig.saleGroups) {
  //     if (sg.type == SaleGroupType.subscr || sg.type == SaleGroupType.nonRenewingSubscr) {
  //       if (user.isUnlockSubscrSale) saleGroups.add(sg);
  //     }
  //     if (sg.type == SaleGroupType.points) {
  //       if (user.isUnlockPointSale) saleGroups.add(sg);
  //     }
  //   }
  //   return saleGroups;
  // }
}