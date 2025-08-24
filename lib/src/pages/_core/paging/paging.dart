import 'package:flutter/material.dart';
import 'package:hbase/hbase.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class Paging {

  /// 该方法封装了 [Pager] 和 [PagingController] 的逻辑，重点是同步 [Pager] 和 [PagingController] 之间
  /// 的分页状态信息
  static nextPage<T>(
    int pageNum, 
    Pager<T> pager, 
    PagingController<int, T> pagingController, 
    BuildContext context,
  ) async {
    try {
      debugPrint('$Paging<$T>.nextPage calls, with param nextPage: $pageNum');
      final stopwatch = Stopwatch()..start();
      List<T> objs = await pager.nextPage();
      debugPrint('$Paging<$T>.nextPage, get totally ${objs.length} remote objs, execution time: ${stopwatch.elapsed}');
      /// 下面的步骤是同步 pagingController 于 postPager 的分页状态，因为滑动分页目前是通过 pagingController 控制的，比如是否是最后一页等状态逻辑
      /// 如果获取到的数据与分页数据相等，则证明还有更多分页数据可被获取
      /// 重要更新，因为 profile page 中的最新标签中会获取额外最多 3 个的 pinned posts，因此这种情况下 objs.length 会超过 [pager.pageSize] 的
      /// 长度，因此为了应对这种情况，条件从 == 放宽为 >= 了；
      if (objs.length >= pager.pageSize) {
        final nextPageNum = pageNum + 1;
        // 特别注意，即便是 posts 经过 filter 后长度为 0，这里仍然要追加，其目的是将 nextPageNum 赋值给 pagingController
        if (context.mounted) pagingController.appendPage(objs, nextPageNum);
      }
      // 如果获取到的数据已经小于一页的数据量了，则说明没有更多数据可被获取了
      else if (objs.length < pager.pageSize) {
        // 一旦调用 appendLastPage 则 pagingController 便不会再触发分页事件了
        if (context.mounted) pagingController.appendLastPage(objs);
      }
      // 为什么要禁止这种情况，答案简第一个 if 分支中的注解
      // else {
      //   throw '$Paging<$T>.nextPage, objs length can not bigger than ${pager.pageSize}';
      // }      
    } catch (e, stacktrace) {
      // No specified type, handles all
      debugPrint('Something really unknown throw from $Paging<$T>.nextPage: $e, statcktrace below: $stacktrace');
      /// 如果发生错误记得一定要交给 pagingController 由它负责处理        
      /// 但是必须确保 pagingController 没有被销毁才能这么做，否则会报错；使用 if(mounted) 即可保证没有被销毁
      if (context.mounted) {
        pagingController.error = e;
      }
    }
  }

}