import 'package:flutter/material.dart';
import 'package:hbase/hbase.dart';
import 'package:sycomponents/components.dart';

class PostFullScreenListPage extends StatefulWidget {
  /// 预加载第一页数据，通常伴随 [chosedPost] 一起使用
  final List<Post>? firstPagePosts;
  /// 通常从 [PostGridList] 点击进入到指定 [chosedPost]，作为第一个展示的 Post；
  /// 如果指定了，那么 [firstPagePosts] 必须不能为空
  final Post? chosedPost;
  /// 设置滑动到距离最后多少个 posts 的时候开始加载下一个分页
  final int distanceCountToPreLoad;

  /// throttle id 可以限制多个相同的 throttle
  static const String loadNextThrottleName = 'load-next-page'; 
  /// 时间尽量设置长一些，避免 preload 与 final page load 争用，试想，如果用户滑动非常快，在 preload
  /// 还没有返回的时候，已经触达了最后一页，那么如果没有 Throttle 设置的话，两者会并发加载分页，造成争用；
  /// 因此为了避免这种情况发生，throttle 时长应该尽量长；
  static const int loadNextPageThrottleMilseconds = 3000;

  static Function nextPage;

  const PostFullScreenListPage({
    super.key, 
    this.firstPagePosts, 
    this.chosedPost, 
    required this.distanceCountToPreLoad
  });

  @override
  State<PostFullScreenListPage> createState() => _PostFullScreenListPageState();
}

class _PostFullScreenListPageState extends State<PostFullScreenListPage> {
  /// 只有异步加载第一分页需要 loading
  bool isFirstPageLoading = false;  
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
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    /// 使用 Listener 来监听用户手指的 up drag 事件；其目的是当用户翻到最后一页后，追加下一个分页的内容；
    /// 
    return PageView.builder(
      itemCount: posts.length,
      controller: pageController,
      scrollDirection: Axis.vertical, // 滑动方向为垂直方向，默认是水瓶方向
      // physics: const NeverScrollableScrollPhysics(),
      allowImplicitScrolling: true, // 预加载 1 个页面
      onPageChanged: (int index) {
        debugPrint("$PostFullScreenListPage, onPageChanged, the current page index: $index");
    
        if (index <= posts.length - 1) {
          // 如果当前 post 是 preload post 那么则执行预加载；
          preloadPostMet(index, () {
            nextPage().then((posts) {
              // 因为这里不更新页面，因此应该将其缓存到 cached posts 中；
              cachedNextPosts = [];  // reset
              cachedNextPosts!.addAll(posts); 
            });
          });
        } else  {
          debugPrint('$index is overflow, _posts not ready yet');
        }
      },
      /// 注意由于预加载的原因，这里的 index 可能是下一页的 post 的了，因此它不能作为 current page post.
      /// 要准确的获得 current page post 需要使用到 [onPageChanged] 方法
      itemBuilder: (BuildContext context, int index) {
        var post = posts[index];
        return DefaultCenterSlotPage(post: post);
      },
    );
  }
}

class DefaultCenterSlotPage extends StatelessWidget {
  final Post post;
  final AlignmentGeometry alignment;

  const DefaultCenterSlotPage({
    super.key, 
    required this.post,
    this.alignment = Alignment.center
  });

  @override
  Widget build(BuildContext context) {
    // convert post slots to carousel slots
    List<Slot> slots = [];  // Carousel slots
    for (var slot in post.slots) {
      slots.add(Slot(width: post.width, height: post.height, picUrl: slot.pic, videoUrl: slot.video));
    }
    return Container(
      alignment: alignment,
      child: AutoKnockDoorShowCaseCarousel(slots: slots)
    );
  }
}
