import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hbase/hbase.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:sycomponents/components.dart';

/// 误删：下面两个导入是为了验证 blur album 抖动的问题所导入的
// import 'package:blur/blur.dart';
// import 'package:cached_network_image/cached_network_image.dart';

typedef OnCellTapped = Future<int?> Function(List<Post> posts, Post post, Pager<Post> postPager);

/// post album/grid list 应该共享一个抽象类；或者应该只有一个 abstract PostGridList 然后由子类实现自己的逻辑即可；
/// 
/// 有关 scrollTo 的说明：默认 [PostAlbumListView] 是通过 [AutoScrollController] 封装的，使得返回此页面的时候，
/// 可以通过 return index 进行 [_PostAlbumListViewState.scrollTo]；但是如果父组件使用的是 [NestedScrollView]
/// 那么就不能使用 [AutoScrollController] 否则无法和 [NestedScrollView] 中的其它组件一同滚动；
/// 
/// 另外一个比较奇怪的是，在 Swapface 项目中 scrollTo 是将目标 cell 定位到当前页面中 album 的顶部，但是现在却在底部？
/// 还不清楚具体原因，因为代码都是一样的呀；
/// 
class PostAlbumListView extends StatefulWidget {
  final Pager<Post> postPager;
  /// 点击 Cell 后的执行逻辑由该回调函数提供；该回调函数可以返回一个 post 用于 scrollTo
  final OnCellTapped onCellTapped;
  /// 如果父组件使用的是 [NestedScrollView] 那么就不能使用 [AutoScrollController] 否则无法和 [NestedScrollView]
  /// 中的其它组件一同滚动；比如在 [ProfilePage] 中因为其使用了 [NestedScrollView] 这里的 [isEnableAutoScroll]
  /// 就应该被设置为 false 即不要启用 [AutoScrollController]
  final bool isEnableAutoScroll;

  const PostAlbumListView({
    super.key, 
    required this.postPager, 
    required this.onCellTapped,
    this.isEnableAutoScroll = false,
  });

  @override
  State<PostAlbumListView> createState() => _PostAlbumListViewState();
}

class _PostAlbumListViewState extends State<PostAlbumListView> {

  /// 注意，后台是从 1 开始分页的，因此这里务必设置为 1
  late PagingController<int, Post> pagingController;
  late AutoScrollController autoScrollController;

  @override
  void initState() {
    super.initState();
     pagingController = PagingController(
      firstPageKey: 1, 
      /// invisibleItemsThreshold 当滑动到还剩下多少个不可见 items 的时候加载下一页，默认是 3 个，这里重载一下设置得多一些
      invisibleItemsThreshold: 6
    );
    /// 想了想，如果 isEnabaledAutoScroll 为 false 这里初始化它无妨，大不了这里初始化了以后不使用即可
    autoScrollController = AutoScrollController(
      /// 这里设置的是当返回此页面后，窗口的边界位置；比如如果内容已经延伸到 bottom appbar 的位置了，那么可以
      /// 通过设置 viewportBoundaryGetter: () => Rect.fromLTRB(0, 0, 0, Screen.bottomAppBarHeight(context)
      /// 的方式设置底部偏移即可绕过 bottom appbar 的高度；但是目前我的 Hbase 系统都没有延伸到 bottom appbar
      /// 的应用场景，因此这里就全部都 hard code 为 0 了，因为不想把一个简单的组件搞得那么复杂什么都要考虑；
      viewportBoundaryGetter: () => const Rect.fromLTRB(0, 0, 0, 0),
      axis: Axis.vertical
    ); // 核心到底使用什么样的 scrollController 由实现类提供
    
    // 监听分页回调，注意参数 pageKey 就是 PageNum，只是该值现在由框架维护了，干脆直接将 pageKey 更名为 pageNum
    pagingController.addPageRequestListener((pageNum) async {
      debugPrint('pagingController trigger the nextPage event with pageNum: $pageNum');
      await Paging.nextPage(pageNum, widget.postPager, pagingController, context);
    });

    /// 误删，标记一下：上面的 pageRequestListener 会触发首页的加载，然后这里又会触发一次首页的加载，结果会导致数据重复
    /// 因此这里就没有必要自己手动的去触发加载第一页了；
    // WidgetsBinding.instance.addPostFrameCallback( (_) async {
    //   if (mounted) {
    //     debugPrint('$PostAlbumList, after cached posts added, then fetch the first page immediatelly');
    //     await nextPage(1);  // 注意这里才开始正式加载远程第 1 页面
    //   }
    // });
  }
  
  @override
  void dispose() {
    pagingController.dispose();
    autoScrollController.dispose();
    super.dispose();
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
        // 备注，如果这里设置为 null，那么会从上找到最近的一个 ScrollController
        scrollController: widget.isEnableAutoScroll ? autoScrollController : null,
        // 定义一行多少个元素
        crossAxisCount: 3,  
        // 纵轴两两元素之间的 gap
        mainAxisSpacing: 1,   
        // 横轴两两元素之间的 gap
        crossAxisSpacing: 1,  
        builderDelegate: PagedChildBuilderDelegate<Post>(
          itemBuilder: (context, post, index) => cellCreator(post, index),
          // 经过测试该回调只会被处罚一次
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

  /// 核心就是 [pagingController.refresh] 会触发 [pagingController.addPageRequestListener] 然后立刻调用 [nextPage]
  /// 后去加载第一页数据；其背后逻辑是，[pagingController.refresh] 中会调用语句 `pagingController.itemList = null` 导致
  /// [pagingController.addPageRequestListener] 被触发
  pullRefresh() {
    widget.postPager.reset();
    pagingController.refresh();
  }  

  /// 只有当 [isEnableAutoScroll] 被激活的情况下才需要处理返回时 scrollTo 相关逻辑
  Widget cellCreator(Post post, int index) {   
    return GestureDetector(
      onTap: () async {
        int? i = await widget.onCellTapped(pagingController.itemList!, post, widget.postPager);
        debugPrint("$PostAlbumListView, navback with return index: $i, and isEnableAutoScroll: ${widget.isEnableAutoScroll}");
        if (i != null && widget.isEnableAutoScroll) {
          scrollTo(i);
        }
      },              
      child: widget.isEnableAutoScroll 
      ? AutoScrollTag(
          key: ValueKey(post.shortcode),
          controller: autoScrollController,
          index: index,
          child: Obx(() => getCell(post)))
      : Obx(() => getCell(post)),
    );

  }

  /// this should be abstract, but here we provide the default impl
  /// 备注：CachedImage 其实也可以不用输入 width 和 height，但是为了避免在图片加载失败后，因为没有尺寸信息而
  ///      导致图片的长宽被压缩只有文本大小而导致布局的问题，建议是加上 width/height.
  Widget getCell(Post post) {
    final width = Math.round(Screen.width(context) / 3, fractionDigits: 2);
    // 首先构建 badgeIcons
    var badgeIcons = <BadgeIcon>[];
    if (post.isPinned == true) {
      badgeIcons.add(BadgeIcon(
        location: BadgeIconLocation.leftTop, 
        icon: const Icon(Icons.push_pin, color: Colors.white, size: 26)));
    }
    if (post.type == PostType.album) {
      badgeIcons.add(BadgeIcon(
        location: BadgeIconLocation.rightTop, 
        icon: const Icon(IconFont.icon_sy_images, color: Colors.white)));
      // return BadgedImage(imgUrl: post.thumbnail, imgWidth: width, imgHeight: height, badgeIcons: [badgeIcon]);
    }
    else if (post.type == PostType.video) {
      badgeIcons.add(BadgeIcon(
        location: BadgeIconLocation.rightTop, 
        icon: const Icon(IconFont.icon_sy_video, color: Colors.white)));
    }
    // 然后创建 img
    dynamic img = CachedImage(imgUrl: post.thumbnail, width: width);
    if (!HBaseUserService.user.isUnlockBlur && post.blur == BlurType.blur) { 
      img = BlurrableImage(child: img, unlockable: false, blurDepth: post.blurDepth);
      /// 误删，以下代码是为了验证 blur 情况下拖动 album 会有图片边缘一个像素的线条抖动的问题；通过下面直接使用 blur 代码的方式
      /// 可以确认是 Blur 框架的问题；看来要彻底解决这个问题，就必须自己写 Blur 的代码逻辑了；
      /// TODO 上面的有关 album Blur 抖动任务留到后面去做吧，毕竟已经知道了 root cause 是什么了
      // img = Blur(
      //   blur: BlurDepthService.getBlurDepthValue(post.blurDepth ?? BlurDepth.medium),
      //   blurColor: Theme.of(context).primaryColor,
      //   child: img,
      //   // 即便是使用下面的原生 CachedNetworkImage 也是一样的
      //   // child: CachedNetworkImage(imageUrl: post.thumbnail,)
      // );
    }
    if (badgeIcons.isNotEmpty) img = BadgedImage(img: img, badgeIcons: badgeIcons);
    return img;
  }

  scrollTo(index) {
    if (pagingController.itemList != null && pagingController.itemList!.isNotEmpty && mounted) {
      debugPrint('navback, scrollTo: $index');
      // scrollController.scrollToIndex(index, preferPosition: AutoScrollPosition.begin);
      autoScrollController.scrollToIndex(index);
      autoScrollController.highlight(index);
    }
  }  

  /// 过滤掉已经加载的元素
  @Deprecated('') 
  // ignore: unused_element
  __filterPosts(List<Post> posts) {
    if (pagingController.itemList != null && pagingController.itemList!.isNotEmpty) {
      posts = posts.where((icmPost) => pagingController.itemList!.contains(icmPost) == false).toList();
      debugPrint('$PostAlbumListView.__filterPosts, after filter duplicates, get totally ${posts.length} remote posts');
    }
    return posts;
  }  

}

