import 'package:flutter/material.dart';

/// 初衷：
/// 最终还是延用 [Pager] 最主要的原因是因为可以满足这样的一种场景：即从 PostGridList 页面点击某个
/// 帖子进入 [PostList] 的场景，这样这两个组件可以共同使用同一个 [PostPager] 实例进行分页；
/// 
/// 抽象：
/// 而进一步将其抽象为 [Pager] 因为有很多分页都需要使用，比如 profile
/// 
abstract class Pager<T> {
  int pageNum;
  int pageSize;
  bool isLastPage = false;

  Pager({
    this.pageNum = 1,
    this.pageSize = 12,
  });

  /// [pageSize] 一页大小  
  /// [pageNum] 获取下一分页的页号
  /// 该方法往往需要通过网络异步获取，因此是 async/await 的异步写法
  Future<List<T>> nextPage() async {
    debugPrint('$Pager.nextPage calls with pageNum: $pageNum, pageSize: $pageSize');

    if (isLastPage){
      debugPrint('$Pager.nextPage, the last page met, directy return []');
      return [];  // 如果已经没有更多内容了则直接返回 []
    }

    List<T> posts = await fetchNextPage();

    if (posts.length < pageSize) {
      debugPrint('last page reached...');
      isLastPage = true;
    }

    debugPrint('$Pager.nextPage calls returns with pageNum: $pageNum totally get ${posts.length} posts');
    
    // 只有当真正获取到了分页数据才能增 1
    if (posts.isNotEmpty) {
      pageNum = pageNum + 1;
      debugPrint('$Pager.nextPage, the pageNum has been increased to $pageNum because the returned remote posts length > 0');
    }
    
    return posts;
  }

  /// 为 pull request 准备的，下拉更新读取第一页，此时需要将 [Pager] 重置
  reset() {
    pageNum = 1;
    isLastPage = false;
  }

  /// 用户唯一需要实现的方法，获取分页的具体实现方法
  /// 注意，如果获取下一个分页失败，需要返回 [FetchNextPageFail] 异常，相关组件会根据该异常来提示页面重试
  Future<List<T>> fetchNextPage();

}