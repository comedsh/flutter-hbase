import 'package:appbase/appbase.dart';
import 'package:hbase/hbase.dart';

class ChannelTagPostPager extends Pager<Post> {
  final List<String> chnCodes;
  List<String>? tagCodes;
  final bool isReelOnly;
  /// 该分页器 [Pager] 目前会被多个页面共用，我想知道是哪个具体页面使用的，供后台子应用可以单独定制；
  final PageLabel pageLabel;

  /// 获取一个或者多个 channel 中的 posts，分页按照一个 profile 一个 post 的方式返回
  ChannelTagPostPager({
    super.pageNum, 
    super.pageSize, 
    required this.chnCodes, 
    this.tagCodes,
    required this.isReelOnly,
    required this.pageLabel
  });

  @override
  Future<List<Post>> fetchNextPage() async {
    var chnCodesStr = chnCodes.join(',');
    var tagCodesStr = tagCodes?.join(',');

    /// ppg: Post Page 的简写
    var r = tagCodesStr == null
      ? await dio.get('/post/chn/ppg/$pageNum/$pageSize/$chnCodesStr/$isReelOnly/${pageLabel.name}')
      : await dio.get('/post/chn/tag/ppg/$pageNum/$pageSize/$chnCodesStr/$tagCodesStr/$isReelOnly/${pageLabel.name}');

    return r.data.map<Post>((data) => Post.fromJson(data)).toList();
  }

}

class ProfilePostPager extends Pager<Post> {
  final String profileCode;
  /// 只能是 'new'|'hot' 后台查询的时候会进行判断
  final String sortBy;

  ProfilePostPager({
    super.pageNum, 
    super.pageSize, 
    required this.profileCode, 
    required this.sortBy
  });

  @override
  Future<List<Post>> fetchNextPage() async {
    var r = await dio.get('/post/prf/ppg/$pageNum/$pageSize/$profileCode/$sortBy');
    return r.data.map<Post>((data) => Post.fromJson(data)).toList();
  }

}

class SearchPostPager extends Pager<Post> {
  final String token;
  final List<String>? chnCodes;

  SearchPostPager({
    super.pageNum,
    super.pageSize,
    required this.token,
    this.chnCodes
  });

  @override
  Future<List<Post>> fetchNextPage() async {
    var r = await dio.post('/search/posts', data: {
      'pageNum': pageNum,
      'pageSize': pageSize,
      'token': token,
      'chnCodes': chnCodes
    });
    return r.data.map<Post>((data) => Post.fromJson(data)).toList();
  }

}
