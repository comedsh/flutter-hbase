
import 'package:appbase/appbase.dart';

class HbaseUserService {

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

}