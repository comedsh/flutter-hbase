// ignore_for_file: depend_on_referenced_packages
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:appbase/appbase.dart';
import 'package:hbase/hbase.dart';

class MeLikePostPager extends Pager<Post> {

  MeLikePostPager({super.pageNum, super.pageSize});

  @override
  Future<List<Post>> fetchNextPage() async {
    /// API_GET_USER_LIKE_PAGE_PREFIX -> /u/page/like
    var r = await dio.get('${dotenv.env['API_GET_USER_LIKE_PAGE_PREFIX']}/$pageNum/$pageSize');
    return r.data.map<Post>((data) => Post.fromJson(data)).toList();
  }

}

class MeFavoritePostPager extends Pager<Post> {

  MeFavoritePostPager({super.pageNum, super.pageSize});

  @override
  Future<List<Post>> fetchNextPage() async {
    /// API_GET_UESR_FAVORITE_PAGE_PREFIX -> /u/page/favorite
    var r = await dio.get('${dotenv.env['API_GET_UESR_FAVORITE_PAGE_PREFIX']}/$pageNum/$pageSize');
    return r.data.map<Post>((data) => Post.fromJson(data)).toList();
  }

}

class MeFollowProfilePager extends Pager<Profile> {

  MeFollowProfilePager({super.pageNum, super.pageSize});

  @override
  Future<List<Profile>> fetchNextPage() async {
    /// API_GET_USER_FOLLOW_PAGE_PREFIX -> /u/page/follow
    var r = await dio.get('${dotenv.env['API_GET_USER_FOLLOW_PAGE_PREFIX']}/$pageNum/$pageSize');
    return r.data.map<Profile>((data) => Profile.fromJson(data)).toList();
  }

}

class MeViewhisPostPager extends Pager<Post> {

  MeViewhisPostPager({super.pageNum, super.pageSize});

  @override
  Future<List<Post>> fetchNextPage() async {
    /// API_GET_USER_VIEWHIS_PAGE_PREFIX -> /u/page/viewhis
    var r = await dio.get('${dotenv.env['API_GET_USER_VIEWHIS_PAGE_PREFIX']}/$pageNum/$pageSize');
    return r.data.map<Post>((data) => Post.fromJson(data)).toList();    
  }

}