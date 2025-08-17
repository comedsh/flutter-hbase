import 'package:appbase/appbase.dart';
import 'package:flutter/material.dart';
import 'package:hbase/hbase.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:sycomponents/components.dart';

class HotspotCardListView extends StatefulWidget {
  final List<String>? chnCodes;
  final List<String>? tagCodes;

  const HotspotCardListView({super.key, this.chnCodes, this.tagCodes});

  @override
  State<HotspotCardListView> createState() => _HotspotCardListViewState();
}

class _HotspotCardListViewState extends State<HotspotCardListView> {
  late Pager<Profile> pager;
  final PagingController<int, Profile> pagingController = PagingController(firstPageKey: 1);

  @override
  void initState() {
    super.initState();
    pager = HotestProfilePager(chnCodes: widget.chnCodes, tagCodes: widget.tagCodes);

    /// 监听分页回调，注意参数 pageKey 就是 PageNum，只是该值现在由框架维护了，干脆直接将 pageKey 更名为 pageNum
    /// 唯一需要特别注意的是 PagingController 会自动触发第一页的加载，因此无需手动的去触发第一页加载；
    pagingController.addPageRequestListener((pageNum) async {
      debugPrint('pagingController trigger the nextPage event with pageNum: $pageNum');
      await Paging.nextPage(pageNum, pager, pagingController, context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return PagedListView<int, Profile>(
      pagingController: pagingController,
      builderDelegate: PagedChildBuilderDelegate<Profile>(
        // 加载第一页时候的使用的 loading 组件
        firstPageProgressIndicatorBuilder: (context) => const Center(child: CircularProgressIndicator()),
        // 直接使用 pagingController.refresh 即可重新触发 firstPageProgressIndicatorBuilder 的 loading 过程
        firstPageErrorIndicatorBuilder: (context) => FailRetrier(callback: pagingController.refresh),
        // 如果加载下一页失败后使用的 reloading 组件
        newPageErrorIndicatorBuilder: (context) => 
          NewPageErrorIndicator(
            errMsg: '网络异常，点击重试',
            onTap: () => pagingController.retryLastFailedRequest()),
        // 第一页就没有数据时候所使用的组件
        noItemsFoundIndicatorBuilder: (context) => const Center(child: Text('没有数据'),),
        itemBuilder: (context, profile, index) => 
          Padding(
            padding: EdgeInsets.symmetric(vertical: sp(7), horizontal: sp(22)),
            child: Row(
              children: [
                ProfileAvatar(profile: profile, size: sp(66)),
                SizedBox(width: sp(8)),
                SizedBox(
                  width: Screen.width(context) * 0.53,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(profile.name, style: TextStyle(fontWeight: FontWeight.w500, fontSize: sp(16))),
                      Text(
                        profile.description ?? "",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: sp(13))
                      )
                    ],
                  ),
                ),
                SizedBox(width: sp(8.0)),
                GradientElevatedButton(
                  gradient: LinearGradient(colors: [
                    AppServiceManager.appConfig.appTheme.fillGradientStartColor,
                    AppServiceManager.appConfig.appTheme.fillGradientEndColor
                  ]),
                  width: sp(80),
                  height: sp(32.0),
                  borderRadius: BorderRadius.circular(13.0),
                  onPressed: () {
                  },
                  dense: true,
                  child: Text('关注', style: TextStyle(color: Colors.white, fontSize: sp(14), fontWeight: FontWeight.bold))
                ),
              ],
            ),
          )
      ),
    );
  }

  /// 这个方法的重点是同步 [PostPager] 与 [PagingController] 之间的分页状态；
  @Deprecated('已经被 Paging.nextPage 方法替代了')
  nextPage(pageNum) async {
    try {
      debugPrint('$HotspotCardListView.nextPage calls, with param nextPage: $pageNum');
      final stopwatch = Stopwatch()..start();
      List<Profile> incomingProfiles = await pager.nextPage();
      debugPrint('$HotspotCardListView.nextPage, get totally ${incomingProfiles.length} remote profiles, execution time: ${stopwatch.elapsed}');
      /// 下面的步骤是同步 pagingController 于 postPager 的分页状态，因为滑动分页目前是通过 pagingController 控制的，比如是否是最后一页等状态逻辑
      // 如果获取到的数据与分页数据相等，则证明还有更多分页数据可被获取
      if (incomingProfiles.length == pager.pageSize) {
        final nextPageNum = pageNum + 1;
        // 特别注意，即便是 posts 经过 filter 后长度为 0，这里仍然要追加，其目的是将 nextPageNum 赋值给 pagingController
        if (mounted) pagingController.appendPage(incomingProfiles, nextPageNum);
      }
      // 如果获取到的数据已经小于一页的数据量了，则说明没有更多数据可被获取了
      else if (incomingProfiles.length < pager.pageSize) {
        // 一旦调用 appendLastPage 则 pagingController 便不会再触发分页事件了
        if (mounted) pagingController.appendLastPage(incomingProfiles);
      }
      else {
        throw 'profiles length can not bigger than ${pager.pageSize}';
      }      
    } catch (e, stacktrace) {
      // No specified type, handles all
      debugPrint('Something really unknown throw from $HotspotCardListView.nextPage: $e, statcktrace below: $stacktrace');
      /// 如果发生错误记得一定要交给 pagingController 由它负责处理        
      /// 但是必须确保 pagingController 没有被销毁才能这么做，否则会报错；使用 if(mounted) 即可保证没有被销毁
      if (mounted) {
        pagingController.error = e;
      }
    }
  }
}