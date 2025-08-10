import 'package:appbase/appbase.dart';
import 'package:flutter/material.dart';
import 'package:hbase/hbase.dart';

/// 最终还是沿用 [PostPager] 最主要的原因是因为可以满足这样的一种场景，即是从 PostGridList 页面点击某个
/// 帖子进入 [PostList] 的场景，这样这两个组件可以共同使用同一个 [PostPager] 实例进行分页
abstract class PostPager {
  int pageNum;
  int pageSize;
  bool isLastPage = false;

  PostPager({
    this.pageNum = 1,
    this.pageSize = 12,
  });

  /// [pageSize] 一页大小  
  /// [pageNum] 获取下一分页的页号
  /// 该方法往往需要通过网络异步获取，因此是 async/await 的异步写法
  Future<List<Post>> nextPage() async {
    debugPrint('$PostPager.nextPage calls with pageNum: $pageNum, pageSize: $pageSize');

    if (isLastPage){
      debugPrint('$PostPager.nextPage, the last page met, directy return []');
      return [];  // 如果已经没有更多内容了则直接返回 []
    }

    List<Post> posts = await fetchNextPage();

    if (posts.length < pageSize) {
      debugPrint('last page reached...');
      isLastPage = true;
    }

    debugPrint('$PostPager.nextPage calls returns with pageNum: $pageNum totally get ${posts.length} posts');
    
    // 只有当真正获取到了分页数据才能增 1
    if (posts.isNotEmpty) {
      pageNum = pageNum + 1;
      debugPrint('$PostPager.nextPage, the pageNum has been increased to $pageNum because the returned remote posts length > 0');
    }
    
    return posts;
  }

  /// 为 pull request 准备的，下拉更新读取第一页，此时需要将 [PostPager] 重置
  reset() {
    pageNum = 1;
    isLastPage = false;
  }

  /// 用户唯一需要实现的方法，获取分页的具体实现方法
  /// 注意，如果获取下一个分页失败，需要返回 [FetchNextPageFail] 异常，相关组件会根据该异常来提示页面重试
  Future<List<Post>> fetchNextPage();

}


class ChannelTagPostPager extends PostPager {
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
      ? await dio.get('/posts/chn/ppg/$pageNum/$pageSize/$chnCodesStr/$isReelOnly')
      : await dio.get('/posts/chn/tag/ppg/$pageNum/$pageSize/$chnCodesStr/$tagCodesStr/$isReelOnly');

    return r.data.map<Post>((data) => Post.fromJson(data)).toList();
  }

}

class ProfilePostPager extends PostPager {
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
    var r = await dio.get('/posts/prf/ppg/$pageNum/$pageSize/$profileCode/$sortBy');
    return r.data.map<Post>((data) => Post.fromJson(data)).toList();
  }

}