import 'package:appbase/appbase.dart';
import 'package:hbase/hbase.dart';

class ChannelTagPostPager extends Pager<Post> {
  final List<String> chnCodes;
  List<String>? tagCodes;
  final bool isReelOnly;

  /// 获取一个或者多个 channel 中的 posts，分页按照一个 profile 一个 post 的方式返回
  ChannelTagPostPager({
    super.pageNum, 
    super.pageSize, 
    required this.chnCodes, 
    this.tagCodes,
    required this.isReelOnly
  });

  @override
  Future<List<Post>> fetchNextPage() async {
    var chnCodesStr = chnCodes.join(',');
    var tagCodesStr = tagCodes?.join(',');

    /// ppg: Post Page 的简写
    var r = tagCodesStr == null
      ? await dio.get('/post/chn/ppg/$pageNum/$pageSize/$chnCodesStr/$isReelOnly')
      : await dio.get('/post/chn/tag/ppg/$pageNum/$pageSize/$chnCodesStr/$tagCodesStr/$isReelOnly');

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
