import 'dart:async';

import 'package:appbase/appbase.dart';
import 'package:easy_debounce/easy_throttle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hbase/hbase.dart';
import 'package:sycomponents/components.dart';

/// 之所以将其定义为抽象类是为了能够让子系统拥有最大的自定义的灵活性，相关的实现嘞参考 [DemoPostFullScreenListPage]
class PostFullScreenListView extends StatefulWidget {
  /// 预加载第一页数据，通常伴随 [chosedPost] 一起使用；当然，这里的第一页并不局限于一页 12/24 的数据，而是指
  /// 初始化 [PostFullScreenListView] 时候传入的第一页数据，可能上百条；
  final List<Post>? firstPagePosts;
  /// 通常从 [PostGridList] 点击进入到指定 [chosedPost]，作为第一个展示的 Post；
  /// 如果指定了，那么 [firstPagePosts] 必须不能为空
  final Post? chosedPost;
  final Pager<Post> postPager;
  /// 设置滑动到距离最后多少个 posts 的时候开始加载下一个分页
  final int distanceCountToPreLoad;
  /// 当滑动到新的分页所执行的回调方法
  final ValueChanged<int>? onPageChanged;
  /// throttle id 可以限制多个相同的 throttle
  static const String loadNextThrottleName = 'load-next-page'; 
  /// 时间尽量设置长一些，避免 preload 与 final page load 争用，试想，如果用户滑动非常快，在 preload
  /// 还没有返回的时候，已经触达了最后一页，那么如果没有 Throttle 设置的话，两者会并发加载分页，造成争用；
  /// 因此为了避免这种情况发生，throttle 时长应该尽量长；
  static const int loadNextPageThrottleMilseconds = 3000;

  const PostFullScreenListView({
    super.key, 
    this.firstPagePosts, 
    this.chosedPost, 
    required this.postPager,
    required this.distanceCountToPreLoad,
    this.onPageChanged
  });

  @override
  State<PostFullScreenListView> createState() => _PostFullScreenListViewState();
}

class _PostFullScreenListViewState extends State<PostFullScreenListView> {
  /// 只有异步加载第一分页需要 loading
  /// 记录一个 BUG：在当前情况下即是从 [_loadPreparedFirstPage] 中加载的第一页也要先将此参数设置为 true，目的是
  /// 为了避免 pageController 提前被 [PageView] 拿来初始化了，从而导致从 album -> 此页面定位失败；
  /// 且要注意的是 pageController 必须是在第一个分页加载好以后，通过 [PageController.initialPage] 的定位才会准确。
  bool isFirstPageLoading = true;  
  /// 如果第一分页加载失败，会使用 FailRetrier 进行重试
  bool isFirstPageLoadFail = false; 
  final List<Post> posts = [];
  List<Post>? cachedNextPagePosts;  // 因为分页是提前加载好的，因此先缓存，在触发分页的时候再添加给 _posts  
  late PageController pageController;
  double pointerDownDy = 0.0;
  /// 用来识别用户向上发生了拖拽的距离
  final dragRecognizedDistance = sp(80.0);

  @override
  void initState() {
    super.initState();
    loadFirstPage();
    listenEvents();
  }

  @override
  Widget build(BuildContext context) {
    return 
    isFirstPageLoadFail 
    ? FailRetrier(callback: _loadRemoteFirstPage) 
    : isFirstPageLoading 
      ? const Center(child: CircularProgressIndicator())
      /// 使用 Listener 来监听用户手指的 up drag 事件；其目的是当用户翻到最后一页后，能够判断用户的拖拽事件以决定是否追加下一个分页的内容；
      : Listener(
        // 手机按下时候的回调
        onPointerDown: (e) {
          pointerDownDy = e.position.dy; // 此时手指按下的高度
        },
        // 手指抬起时候的回调
        onPointerUp: (e) {
          handleNextPageIfLastPageMet(e);
        },      
        child: PageView.builder(
          itemCount: posts.length,
          controller: pageController,
          scrollDirection: Axis.vertical, // 滑动方向为垂直方向，默认是水瓶方向
          // physics: const NeverScrollableScrollPhysics(),
          allowImplicitScrolling: true, // 预加载 1 个页面
          /// 注意第一个页面是不会触发该回调的，
          onPageChanged: (int index) {
            debugPrint("$PostFullScreenListView#onPageChanged, the current page index: $index");
            if (index <= posts.length - 1) {
              // 如果滑动到了预加载的位置，那么则执行预加载；
              preloadPostMet(index, () {
                nextPage().then((posts) {
                  // 因为这里不更新页面，因此应该将其缓存到 cached posts 中；
                  cachedNextPagePosts = [];  // reset
                  cachedNextPagePosts!.addAll(posts); 
                });
              });
              /// 特别注意，[onPageChanged] 方法不会在第一个页面显示的时候回调，但是 PostPageChangedNotification 在
              /// 首页就需要监听 [onPageChanged] 事件，因此该 notification 在 initState 方法中又 dispatch 了一次
              PostPageChangedNotification(index).dispatch(context);
              if (widget.onPageChanged != null) widget.onPageChanged!(index);
            } else  {
              debugPrint('$index is overflow, _posts not ready yet');
            }
            
            if (index == 2) ScoreService.notifyScoreSimple();
          },
          /// 注意由于预加载的原因，这里的 index 可能是下一页的 post 的了，因此它不能作为 current page post.
          /// 要准确的获得 current page post 需要使用到 [onPageChanged] 方法
          itemBuilder: (BuildContext context, int index) {
            var post = posts[index];
            return PostFullScreenView(post: post, postIndex: index);
          },
        ),
      );
  }

  Future<List<Post>> nextPage() async {
    // 如果有初始入参 posts，那么第一次分页使用入参的数据；
    debugPrint('nextPage calls, try to load the page with pageNum: ${widget.postPager.pageNum}');
    var pageNum = widget.postPager.pageNum;
    var page = await widget.postPager.nextPage();
    if (pageNum != 1) UserService.sendReloadUserEvent();
    return page;
  }

  /// 需要处理首次加载的逻辑，如果第一页是传入的 posts 则直接使用，否则获取最新的分页
  void loadFirstPage() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // 如果第一页是通过传值传入，那么直接渲染
      // ignore: curly_braces_in_flow_control_structures
      if (widget.firstPagePosts != null) await _loadPreparedFirstPage();
      // 否则则异步获取第一页的数据，然后渲染它
      // ignore: curly_braces_in_flow_control_structures
      else await _loadRemoteFirstPage();
      initPageController();
      /// 因为 onPageChanged 事件不会在第一个页面被 [PageView.onPageChanged] 触发，因此这里需要弥补这个缺陷，即是
      /// 在初始化后的第一个页面也要触发，避免依赖 [PostPageChangedNotification] 事件的方法出现 bug，典型的就是从
      /// PostFullScreenListView -> PostFullScreenListViewPage -> PostAlbumListView 页面过程中返回定位丢失；
      var index = widget.chosedPost == null 
        ? 0 
        : PostPageService.getIndex(widget.firstPagePosts!, widget.chosedPost!)!;
      // debugPrint('$PostFullScreenListView, inital index: $index');
      PostPageChangedNotification(index).dispatch(context);      
    });
  }  

  /// 从参数 [firstPagePost] 中加载第一页
  _loadPreparedFirstPage() async {
    assert(widget.firstPagePosts != null && widget.firstPagePosts!.isNotEmpty);
    await appendPosts(widget.firstPagePosts!);
    setState(() {
      isFirstPageLoading = false;
      isFirstPageLoadFail = false;
    });
  }

  /// 注意如果第一页失败重试也会重用该句柄
  _loadRemoteFirstPage() async {
    try {
      List<Post> page =  await nextPage();
      // 如果加载时间过长，用户退出该页面后该请求返回，然后调用 setState 会因为该组件已经从 tree 中移除而报错；错误描述如下，
      // flutter: Error: setState() called after dispose(): _PostPageFullScreenListState#7161c(lifecycle state: defunct, not mounted)
      // flutter: This error happens if you call setState() on a State object for a widget that no longer appears in the widget tree
      // 因此为了避免这样的情况，使用 mounted 来判断该组件是否依然被挂载在 tree 中
      if (mounted) {
        // posts.addAll(posts_);          
        await appendPosts(page);
        initPageController();
        setState((){
          isFirstPageLoading = false;
          isFirstPageLoadFail = false;
          debugPrint('posts.length: ${posts.length}');
        });
     }    
    } catch (e, stacktrace) {
      debugPrint('$e, statcktrace below: $stacktrace');
      if (mounted) {
        setState((){
          isFirstPageLoading = false;
          isFirstPageLoadFail = true;
        });
      }
      rethrow;
    }
  }  

  /// 注意：pageController 必须是在第一个分页加载好以后，通过 [PageController.initialPage] 的跳转定位才会准确。
  void initPageController() {

    // 设置 initialPage
    pageController = PageController(
      // 通过 initialPage 初始化第一页；如果 chosedPost 被选中，那么第一次跳转的页面就是 chosedPost
      // 对应的页面，因此这里返回其对应的下标；      
      initialPage: widget.chosedPost == null 
        ? 0 
        : widget.firstPagePosts!.indexWhere((p) => p.shortcode == widget.chosedPost!.shortcode),
      // initialPage: 1
    );

    /// 下面是测试有关 PageController listener 的相关试验代码，不要删除
    /// 有关 offset 和 page 的调试输出结果如下
    /// .....
    /// flutter: pageView 滑动的距离 1863.3885458762315  索引 1.999343933343596
    /// flutter: pageView 滑动的距离 1863.474380137969  索引 1.999436030190954
    /// flutter: pageView 滑动的距离 1863.611592869922  索引 1.999583254152277
    /// flutter: pageView 滑动的距离 1863.6661136106834  索引 1.9996417528011625
    /// flutter: pageView 滑动的距离 1864.0  索引 2.0
    /// 可以看到索引值是随着页面逐步进入的，当完整进入后，索引值为整数
    /// 利用 PageController.scrollToPosition 还可以直接跳转到某个页面
    /*
    pageController.addListener(() { 
      // ignore: unused_local_variable
      double initialOffset = pageController.initialScrollOffset;
      // PageView滑动的距离
      // ignore: unused_local_variable
      double offset = pageController.offset;
      // 当前显示的页面的索引
      // ignore: unused_local_variable
      double page = pageController.page!;

      debugPrint("pageView 滑动的距离 $offset 页面索引 $page 初始 offset: $initialOffset");
    });
    */
  }

  /// [index] 当前 post 的下标
  /// [loadNextPageCallback] 当遇到 preload post 的时候执行该回调
  /// 当用户向下滑动到距离最后一个 post 多远的 post 后开始"预加载"下一个数据页。
  void preloadPostMet(int index, Function loadNextPageCallback) {
    var maxIndex = posts.length - 1;      
    if (index == maxIndex - widget.distanceCountToPreLoad) {
      debugPrint('preload post $index met, now try to load the new page');
      /// 使用 throttle 限流，即第一次调用 target method，然后 duration ms 内不再调用；
      /// 使用它的场景是为了避免用户快速下滑很快触底的时候又再次进行了一次 load，即保证在该时间段内不会再次发起 nextpage 请求；
      EasyThrottle.throttle(
        PostFullScreenListView.loadNextThrottleName,   // <-- An ID for this particular throttler
        const Duration(milliseconds: PostFullScreenListView.loadNextPageThrottleMilseconds),   // <-- The throttle duration
        () => loadNextPageCallback()
      );
    }
  }

  /// 当用户滑动至最后一页并且发生了手指向上滑动，触发是否加载下一页事件；是否加载需要通过判定预加载是否成功，如果预加载
  /// 成功则不会触发下一页加载，如果未成功则需要加载
  void handleNextPageIfLastPageMet(PointerUpEvent e) {
    // 在最后一页发生了向上的手指滑动，那么则需要加载新的帖子，然后渲染页面；
    // 1. 如果是最后一页了
    lastPageMet((){
      // 2. 如果用户上拽发生了
      verticalUpDragMet(e, pointerDownDy, dragRecognizedDistance, () {
        // 3. 根据 preload 的结果有不同的处理方式；
        _postsPreloadedSuccess(
          cachedNextPagePosts,  // cachedNextPagePosts 不为空则表示回调成功，相反则表示回调失败
          // successCalblack
          () async {
            // 如果预加载分页成功，则这里直接载入该分页即可 - 实现丝滑的进入下一个分页
            // 经过测试，是可以非常丝滑的自动的滑动到新增的下一页的
            // posts.addAll(cachedNextPagePosts!);
            await appendPosts(cachedNextPagePosts!);
            setState((){ });
          }, 
          // failCallback 
          () {
            // 如果预加载分页失败，那么这里需要继续加载分页；
            // 使用 throttle 限流，即第一次调用 target method，然后 duration ms 内不再调用
            EasyThrottle.throttle(
              PostFullScreenListView.loadNextThrottleName,   // <-- An ID for this particular throttler
              const Duration(milliseconds: PostFullScreenListView.loadNextPageThrottleMilseconds),   // <-- The throttle duration
              () { 
                // 加载新的分页
                nextPage().then((posts) async {
                  /// 最后一页了，无法加载更多分页了
                  /// 细节：不能通过 preLoad 判断是否最后一页了，因为 preLoad 可能失败；
                  if (posts.isEmpty) {  
                    Get.snackbar('到底了', '已经触底，没有更多内容了', snackPosition: SnackPosition.BOTTOM);
                  } else {       
                    // posts.addAll(posts);                       
                    await appendPosts(posts);
                    setState(() {});
                  }
                // ignore: invalid_return_type_for_catch_error
                }).catchError((err) => debugPrint('when fetch the last page, get the error: $err'));
              }
            );
          }
        );
      });
    });
  }

  void lastPageMet(Function callback) {
    // 在最后一页发生了滑动，那么则需要加载新的帖子，然后渲染页面；
    // 备注：下面是另外一种解法，从 pageController.page 中获取当前正在展示的 page index.
    if (posts.length - 1 == pageController.page) {
      callback();
    }
  }  

  void verticalUpDragMet(PointerUpEvent e, double pointerDownDy, double dragRecognizedDistance, callback) {
    var pointerUpDy = e.position.dy;  // 此时手指抬起时候的高度
    // debugPrint('up ${pointerUpDy}');                
    // 判断向上的拖动是否发生（只有超过了预定距离才会认为是拖动发生）
    var verticalDragDistance = pointerDownDy - pointerUpDy;
    debugPrint('verticalDragDistance: $verticalDragDistance');
    if (verticalDragDistance >= dragRecognizedDistance) {
      debugPrint('vertical drag of the last page has been detected, load the next page');
      callback();
    }

  }

  /// 预加载成功与否直接决定到用户浏览到最后一页后上拽页面是否加载下一个分页的行为，如果预加载成功则不需要加载新的分页
  /// 否则则需要
  void _postsPreloadedSuccess(List<Post>? cachedNextPosts, Function successCallback, Function failCallback) {
    // 如果预加载分页成功，则这里直接载入该分页即可 - 实现丝滑的进入下一个分页
    if (cachedNextPosts != null && cachedNextPosts.length > 1) {
      successCallback();
    } else {
      failCallback();
    }
  }

  listenEvents() {
    HBaseStateManager hbaseState = Get.find();
    ever(hbaseState.unseenPostEvent, (Post? p) async {
      debugPrint('$PostFullScreenListView, unseen post event received, block profile: ${p?.shortcode}');
      await removeUnseenPostHandler(p!.shortcode);
    });
    ever(hbaseState.blockProfileEvent, (Profile? p) async {
      debugPrint('$PostFullScreenListView, block profile event received, unseen post: ${p?.code}');
      await removeProfileEventHandler();
    });    
  }

  /// 将某个帖子从 posts 中删除，对应的是屏蔽功能
  removeUnseenPostHandler(String shortcode) async {
    await PostUnseenService.saveUnseenPost(shortcode);
    setState(() => posts.removeWhere((Post p) => p.shortcode == shortcode));
  }

  /// 某个 profile 被拉黑的事件处理句柄，讲相关的 posts 清理掉
  removeProfileEventHandler() async {
    var blockedProfiles = await BlockProfileService.getAllBlockedProfiles();
    var blockedProfileCodes = blockedProfiles.map((p) => p.code).toList();
    setState(() => posts.removeWhere((Post p) => blockedProfileCodes.contains(p.profileCode)));
  }

  /// 该方法中过滤掉了屏蔽的 posts 以及关联 blocked profiles 的 posts
  appendPosts(List<Post> newPosts) async {
    var unSeenPosts = await PostUnseenService.loadUnseenPosts();
    var blockedProfiles = await BlockProfileService.getAllBlockedProfiles();
    var blockedProfileCodes = blockedProfiles.map((p) => p.code).toList();
    // 注意直接从源 newPosts 中进行了删除
    newPosts.removeWhere((p) => 
      unSeenPosts.contains(p.shortcode) || blockedProfileCodes.contains(p.profileCode)
    );
    posts.addAll(newPosts);
  }

}
