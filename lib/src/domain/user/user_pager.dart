

import 'package:appbase/appbase.dart';
import 'package:hbase/hbase.dart';

class MeLikePostPager extends Pager<Post> {

  MeLikePostPager({super.pageNum, super.pageSize});

  @override
  Future<List<Post>> fetchNextPage() async {
    var r = await dio.get('/u/page/like/$pageNum/$pageSize');
    return r.data.map<Post>((data) => Post.fromJson(data)).toList();    
  }

}

class MeFavoritePostPager extends Pager<Post> {

  MeFavoritePostPager({super.pageNum, super.pageSize});

  @override
  Future<List<Post>> fetchNextPage() async {
    var r = await dio.get('/u/page/favorite/$pageNum/$pageSize');
    return r.data.map<Post>((data) => Post.fromJson(data)).toList();    
  }

}

class MeFollowProfilePager extends Pager<Profile> {

  MeFollowProfilePager({super.pageNum, super.pageSize});

  @override
  Future<List<Profile>> fetchNextPage() async {
    var r = await dio.get('/u/page/follow/$pageNum/$pageSize');
    return r.data.map<Profile>((data) => Profile.fromJson(data)).toList();
  }

}

class MeViewhisPostPager extends Pager<Post> {

  MeViewhisPostPager({super.pageNum, super.pageSize});

  @override
  Future<List<Post>> fetchNextPage() async {
    var r = await dio.get('/u/page/viewhis/$pageNum/$pageSize');
    return r.data.map<Post>((data) => Post.fromJson(data)).toList();    
  }

}