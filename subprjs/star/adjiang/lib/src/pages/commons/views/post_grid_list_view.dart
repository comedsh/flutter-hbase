// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hbase/hbase.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:sycomponents/components.dart';
import 'package:appbase/appbase.dart';
import 'package:get/get.dart';

class PostGridListView extends StatefulWidget {
  final Pager<Post> postPager;
  final TabData tab;
  const PostGridListView({super.key, required this.postPager, required this.tab});

  @override
  State<PostGridListView> createState() => _PostGridListViewState();
}

class _PostGridListViewState extends State<PostGridListView> {
  late PagingController<int, Post> pagingController;
  late AutoScrollController autoScrollController;

  @override
  void initState() {
    super.initState();
    initPageController();
    initAutoScrollController();
    listenEvents();
  }

  @override
  void dispose() {
    pagingController.dispose();
    autoScrollController.dispose();
    super.dispose();
  }  

  initPageController() {
    pagingController = PagingController(
      firstPageKey: 1, 
      /// invisibleItemsThreshold 当滑动到还剩下多少个不可见 items 的时候加载下一页，默认是 3 个
      /// 备注：之前这个值设置为了 6，结果初始情况下就会加在 2 页；因此我怀疑，在 [PostAlbumListView] 中是不是按照行数来计算的？
      invisibleItemsThreshold: 3
    );    
    // 监听分页回调，注意参数 pageKey 就是 PageNum，只是该值现在由框架维护了，干脆直接将 pageKey 更名为 pageNum
    // 特别注意的是，第一次页面初始化会自动触发该回调加载第一页内容
    pagingController.addPageRequestListener((pageNum) async {
      debugPrint('${widget.tab.name} page, pagingController trigger the nextPage event with pageNum: $pageNum');
      await Paging.nextPage(pageNum, widget.postPager, pagingController, context);
      // removedRevantPostsFromBlockedProfiles();
      if (pageNum != 1) UserService.sendReloadUserEvent();
    });
  }  

  initAutoScrollController() {
    /// 想了想，如果 isEnabaledAutoScroll 为 false 这里初始化它无妨，大不了这里初始化了以后不使用即可
    autoScrollController = AutoScrollController(
      /// 这里设置的是当返回此页面后，窗口的边界位置；比如如果内容已经延伸到 bottom appbar 的位置了，那么可以
      /// 通过设置 viewportBoundaryGetter: () => Rect.fromLTRB(0, 0, 0, Screen.bottomAppBarHeight(context)
      /// 的方式设置底部偏移即可绕过 bottom appbar 的高度；但是目前我的 Hbase 系统都没有延伸到 bottom appbar
      /// 的应用场景，因此这里就全部都 hard code 为 0 了，因为不想把一个简单的组件搞得那么复杂什么都要考虑；
      viewportBoundaryGetter: () => const Rect.fromLTRB(0, 0, 0, 0),
      axis: Axis.vertical
    ); // 核心到底使用什么样的 scrollController 由实现类提供
  }

  listenEvents() {
    HBaseStateManager hbaseState = Get.find();
    ever(hbaseState.unseenPostEvent, (Post? p) async {
      debugPrint('unseen post event received, block profile: ${p?.shortcode}');
      if(context.mounted) await removeUnseenPostHandler(p!.shortcode);
    });    
    ever(hbaseState.blockProfileEvent, (Profile? p) async {
      debugPrint('$PostAlbumListView, block profile event received, block profile: ${p?.code}');
      removedRevantPostsFromBlockedProfiles();
      if(context.mounted) setState((){});
    });
  }  

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        await HapticFeedback.heavyImpact();  // 给一个震动反馈。
        await pullRefresh();
      },      
      child: PagedMasonryGridView.count(
        // 解决 [PostGridListView] 的 items 太少导致 Pull Refresh（下拉更新）不会被触发的问题，参考
        // https://stackoverflow.com/questions/57519765/refresh-indicator-doesnt-work-when-list-doesnt-fill-the-whole-page
        physics: const AlwaysScrollableScrollPhysics(),      
        pagingController: pagingController,
        scrollController: autoScrollController,
        crossAxisCount: 2,  // 设置多少列
        mainAxisSpacing: 6,  // 设置纵向两个元素间间隔
        crossAxisSpacing: 8,  // 设置横向两个元素间间隔
        builderDelegate: PagedChildBuilderDelegate<Post>( 
          itemBuilder: (context, post, index) => getCell(post, index),
          // 经过测试该回调只会被触发一次
          firstPageProgressIndicatorBuilder: (_) => const Center(child: CircularProgressIndicator()), // 自定义第一页 loading 组件
          // 直接使用 pagingController.refresh 即可重新触发 firstPageProgressIndicatorBuilder 的 loading 过程
          firstPageErrorIndicatorBuilder: (context) => FailRetrier(callback: pagingController.refresh),
          newPageErrorIndicatorBuilder: (context) => 
            NewPageErrorIndicator(
              errMsg: '网络异常，点击重试',
              onTap: () => pagingController.retryLastFailedRequest()),
          noItemsFoundIndicatorBuilder: (context) => const Center(child: Text('没有数据'),)
        )
      ),
    );
  }

  Widget getCell(Post post, int index) {
    return AutoScrollTag(
      key: ValueKey(post.shortcode),
      controller: autoScrollController,
      index: index,
      child: cellBuilder(post, index)
    );
  }

  Widget cellBuilder(Post post, int index) {
    var coverImg = post.slots[0];  // 使用第一个 slot image 作为封面
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,  // 左对齐
      children: [
        GestureDetector(
          onTap: () async {
            var returnedIndex = await Get.to<int>(() => 
              PostFullScreenListViewPage(
                posts: pagingController.itemList!, 
                post: post, 
                postPager: widget.postPager,
                title: widget.tab.name,
                isShowUploadTs: widget.tab.id == 'latest',
            ));
            scrollTo(returnedIndex);
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(16.0)),
                child: PostCoverService.attachBadgedIcon(
                  post: post, 
                  img: CachedImage(width: coverImg.width, aspectRatio: coverImg.width / coverImg.height, imgUrl: coverImg.pic), 
                  isPaintPinned: false
                )
              ),
              Padding(
                padding: EdgeInsets.all(sp(6.0)),
                child: Text(
                  post.captionRaw ?? "",
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  softWrap: true
                ),
              ),
            ],
          ),
        ),
        Column(
          /// 为了保证整个组件不越界，在 Row 组件上添加了 SingleChildScrollView 控件，但是它会破坏默认的左对齐布局，因此这里必须使用 start 强制约束；
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(top: sp(6), left: sp(12), right: sp(6), bottom: sp(6)),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    // 1) profile avatar and name
                    GestureDetector(
                      onTap: () => Get.to(() => ProfilePage(profile: post.profile)),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          ProfileAvatar(
                            profile: post.profile, 
                            size: sp(28), 
                            onTap: () => Get.to(() => ProfilePage(profile: post.profile)) 
                          ),
                          SizedBox(width: sp(8)),
                          SizedBox(
                            width: sp(96),
                            child: Text(
                              post.profile.name, 
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: sp(13), fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                    /// 2）点赞喜欢
                    StatefulLikeButton(post: post, isVertical: false, iconSize: sp(22), fontSize: sp(13),),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  scrollTo(index) {
    if (pagingController.itemList != null && pagingController.itemList!.isNotEmpty && mounted) {
      debugPrint('navback, scrollTo: $index');
      // scrollController.scrollToIndex(index, preferPosition: AutoScrollPosition.begin);
      autoScrollController.scrollToIndex(index);
      autoScrollController.highlight(index);
    }
  }

  /// 核心就是 [pagingController.refresh] 会触发 [pagingController.addPageRequestListener] 然后立刻调用 [nextPage]
  /// 后去加载第一页数据；其背后逻辑是，[pagingController.refresh] 中会调用语句 `pagingController.itemList = null` 导致
  /// [pagingController.addPageRequestListener] 被触发
  pullRefresh() {
    widget.postPager.reset();
    pagingController.refresh();
  }

  removedRevantPostsFromBlockedProfiles() async {
    final blockedProfiles = await BlockProfileService.getAllBlockedProfiles();
    final blockedProfileCodes = blockedProfiles.map((p) => p.code).toList();
    pagingController.itemList?.removeWhere((p) => blockedProfileCodes.contains(p.profileCode));
  }  

  removeUnseenPostHandler(String shortcode) async {
    await PostUnseenService.saveUnseenPost(shortcode);
    // setState(() => posts.removeWhere((Post p) => p.shortcode == shortcode));
    pagingController.itemList?.removeWhere((p) => p.shortcode == shortcode);
    setState(() {});
  }  

}
