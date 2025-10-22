
import 'dart:async';

import 'package:appbase/appbase.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_time_ago/get_time_ago.dart';
import 'package:hbase/hbase.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:ionicons/ionicons.dart';
import 'package:sycomponents/components.dart';
import 'package:visibility_detector/visibility_detector.dart';


final compactFormat = NumberFormat.compact(locale: 'zh_CN');


/// 这是一个满屏展示的 post 页面，实现主要是参考 ins 页面的设计；且因为该组件只是提供给 HBase 系统使用，
/// 因此它的实现粒度范围就围绕着 HBase 系统的需要展开，比如包含喜欢、收藏、关注、下载逻辑等等；然而之所以
/// 将其定义为抽象类是让子系统可以按照自己的需求对某些功能进行定制，比如下载行为等等；
/// 
class PostFullScreenView extends StatefulWidget{
  final Post post;
  /// 通常 [PostFullScreenView] 是在列表中展示，这里的 [postIndex] 即表示该 post 在此列表中的下标
  final int postIndex;
  /// 根据现在的业务要求（学抖音的做法）仅在最新的页面中展示，包含分类页中的最新以及 Profile 的最新页面中
  final bool isShowUploadTs;

  /// 解锁 blur 和 translation 逻辑的重要说明
  /// 1. 前言：因为现在解锁逻辑只会放到 [PostFullScreenView] 中，因此将此重要说明放到这里也是合情合理的。
  /// 2. 为了尽量简化程序的复杂性，那么约定是最好的解法，因此约定 HBase 所有的子系统的默认解锁 blur 和翻译
  ///    的方式就是跳转购买基础会员页面；那么剩下一个问题，就是诸如 inshow 那样如果要解锁看快拍的话就需要跳
  ///    转到购买高级会员，那么怎么兼容这种情况？答案是，不能兼容，因为鱼和熊掌不能兼得；现在想到的唯一的解法
  ///    就是在 [ProfilePage] 中去 hard code 这种情况，如果是快拍类型的 tab，那么 hard code 跳转到高
  ///    级订阅；这是基于约定简化程序的必然要面对的问题，否则就会陷入到各种分支各种配置的复杂漩涡中去了，结果
  ///    面向的不是业务，而是系统本身的复杂性了！
  /// 也因此，你可以看到无论是解锁 blur 还是 translation 都是默认跳转到 base subscr sale page.
  /// 
  /// 有关 UserStaying 的说明
  /// 每次 [PostFullScreenView] 可见的时候初始化 userStaying，并生成一个定时器用于监听用户停留时长，一旦
  /// 超过预设的时长 [userStayedMillseconds] 则回调 [userStayed] 方法，此时会销毁定时器，以确保一次展示
  /// 只会触发一次 userStayed 事件；
  const PostFullScreenView({
    super.key, 
    required this.post,
    required this.postIndex,
    this.isShowUploadTs = false
  });

  @override
  State<PostFullScreenView> createState() => _PostFullScreenViewState();
}

class _PostFullScreenViewState extends State<PostFullScreenView> {
  Timer? userStayingTimer;
  DateTime? userStayingStart;
  DateTime? userStayingEnd;
  /// 是否把这个值做成可配置的？不要，减少系统复杂性，如果有更好的值，下个版本更新。
  static const userStayedMillseconds = 2200; 
  /// 解决控制面板定位会因为 [HBaseStateService.isBottomNavigationBarVisible] 通过 [VisibilityDetector] 检测延时
  /// 过程中偏离的问题，通过 [visible] 参数先隐藏控制面板，等待 [HBaseStateService.isBottomNavigationBarVisible] 
  /// 被准确赋值后，在展示；而这个等待很简单，就是通过一个 Timer 控制器等待 n 毫秒以后展示即可。
  /// 
  /// 而因为 PostFullScreenView 每次都会预先加载两个页面，因此只有第一次进入 [PostFullScreenListView] 页面的时候，才会
  /// 有个 n 毫秒延迟展示，而之后向后滑动加载下一页的时候便不会有这个延迟了，因为下一页已经被预先加载了；
  /// 
  var visible = false.obs;

  var isShowEnterProfileTooltip = false.obs;

  @override
  void initState() {
    super.initState();
    debugPrint('$PostFullScreenListView.initState calls, route: ${Get.currentRoute}');
    /// 见 [visible] 参数注解；在 iPhone 11 promax 真机上测试，等待如下的毫秒数比较稳妥；
    Timer(const Duration(milliseconds: 550), () => visible.value = true);
  }

  @override
  void dispose() {
    debugPrint('$PostFullScreenListView.dispose calls');
    // 这里是防御性编程，确保在销毁该组件的时候，绑定在其上的定时器一定被销毁了
    userStayingTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    /// VisibilityDetector 主要用来监视 UserStaying 事件的
    return VisibilityDetector(
      key: Key('${UniqueCode.uniqueShortCode}_${widget.post.shortcode}'),
      onVisibilityChanged: (info) {
        if (info.visibleFraction > 0.8) {
          debugPrint('$PostFullScreenListView, the ${widget.post.shortcode} is visible');
          userStayingStart = DateTime.now();
          /// 实际使用过程中发现会多次触发 inView 条件，即便是我把 inView 调整到 1.0，目前看，会触发两次；那么就会导致 
          /// userStayingTimer 被初始化两次那么就有两个 interval；为了避免影响，务必将上一个 inteval cancel 掉。
          userStayingTimer?.cancel();
          userStayingTimer = Timer.periodic(const Duration(milliseconds: 300), (_) {
            userStayingEnd = DateTime.now();
            var diffMillseconds = userStayingEnd!.difference(userStayingStart!).inMilliseconds;
            if (diffMillseconds > userStayedMillseconds) {
              // 一旦触发了 userStay 那么将 interval 立刻停止避免重复触发 userStay，因此一个页面只需要一次 userStay 即可
              userStayingTimer?.cancel();
              userStayCallback();
            }
          });
        }
        else {
          debugPrint('$PostFullScreenListView, the ${widget.post.shortcode} is inVisible');
          userStayingTimer?.cancel();
        }
      },
      child: Column(
        children: [
          Expanded(
            child: Container(
              alignment: Alignment.center,
              child: createPostPage(context)
            ),
          ),
        ],
      ),
    );
  }

  createPostPage(BuildContext context) {
    return Stack(
      children: [
        AutoKnockDoorShowCaseCarousel(
          slots: widget.post.slots, 
          indicatorPaddingBottom: 10, 
          imageCreator: (String url, double width, double aspectRatio) => 
            Obx(() => PostCarouselService.imageCreator(
              post: widget.post, 
              url: url, 
              width: width, 
              aspectRatio: aspectRatio
            )),
          videoCreator: (String videoUrl, String coverImgUrl, double width, double aspectRatio, BoxFit fit) =>
            Obx(() => PostCarouselService.videoCreator(
              post: widget.post, 
              videoUrl: videoUrl, 
              coverImgUrl: coverImgUrl, 
              width: width, 
              aspectRatio: aspectRatio, 
              fit: fit
            )),
        ),
        
        Obx(() => Visibility(
          visible: visible.value,
          child: Positioned(
            bottom: sp(offsetBottom),
            left: sp(20),
            child: leftPanel(widget.post, context)
          ),
        )),
        Obx(() => Visibility(
          visible: visible.value,
          child: Positioned(
            bottom: sp(offsetBottom),
            // right: sp(20),
            right: 0,
            child: rightPanel(widget.post, context)
          ),
        ))
      ],
    );
  }

  leftPanel(Post post, BuildContext context) {
    /// 使用 SizedBox 限定宽度，这样 text 的 ellipsis overflow 也才会生效
    return SizedBox(
      width: Screen.widthWithoutContext() * 0.7,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// 博主头像、名字和关注元素的控制面板
          Row(
            children: [
              ProfileAvatar(
                profile: post.profile, 
                size: sp(44), 
                /// 为了避免陷入无限的 profile -> post page -> profile -> post page ... 这样的链条中，
                /// 如果当前是从 ProfilePage 中跳转的，那么当点击头像的时候，是回退操作即回退到 profile page，
                /// 这样就可以有效的阻断上述的无限链条... 
                onTap: () { 
                  Get.previousRoute == "/$ProfilePage"
                    ? Get.back<int>(result: widget.postIndex)
                    : Get.to(() => ProfilePage(profile: post.profile));
                  ScoreService.notifyScoreSimple();
                },
              ),
              // profile name
              GestureDetector(
                /// 注释同上
                onTap: () { 
                  Get.previousRoute == "/$ProfilePage"
                    ? Get.back<int>(result: widget.postIndex)
                    : Get.to(() => ProfilePage(profile: post.profile));
                  ScoreService.notifyScoreSimple();                    
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: sp(8.0)),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: <Color>[
                          Colors.black12.withOpacity(0.3),
                          Colors.black12.withOpacity(0.2)
                        ]
                      ),
                    ),
                    child: Obx(() => isShowEnterProfileTooltip.value 
                      ? TooltipShowCase(
                          name: 'enterProfileTooltip',
                          tooltipText: '点击进入我的空间',
                          popupDirection: TooltipDirection.up,
                          showDurationMilsecs: 3200,
                          learnCount: 1,
                          child: _profileName(post),
                        )
                      : ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: sp(160.0)),
                        child: _profileName(post),
                      ), 
                    ),
                  )   
                ),
              ),
              // follow button
              _followButton(post, context),
            ],
          ),
          SizedBox(height: sp(26)),
          /// Caption 区域
          if (post.captionRaw != null)
            // 添加背景色使得文字可以突出展示
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomLeft,
                  end: Alignment.topRight,
                  colors: <Color>[
                    Colors.black12.withOpacity(0.1),
                    Colors.black12.withOpacity(0.1)
                  ]
                ),
              ),
              /// 思路是这样的，如果用户点击展开，则 toggle 替换组件
              child: Caption(
                post: post, 
                maxLines: 7,
                isAllowedTrans: HBaseUserService.user.isUnlockTranslation,
                /// 如果 isAllowedTrans == false，那么将会使用该 unlockTransCallback 进行跳转解锁
                /// 约定，和 unlockBlur 一样加入会员只能开通会员
                unlockTransCallback: () async {
                  var isConfirmed = await showConfirmDialog(
                    context,
                    title: '解锁翻译',
                    content: '加入会员即可解锁翻译',
                    confirmBtnTxt: '加入', 
                    cancelBtnTxt: '不了'
                  );
                  if (isConfirmed) {
                    Get.to(() => SalePage(
                      saleGroups: AppServiceManager.appConfig.saleGroups,
                      initialSaleGroupType: SaleGroupType.subscr,
                      backgroundImage: (AppServiceManager.appConfig as HBaseAppConfig).salePageBackgroundImage,
                    ));
                  }
                },
                // tailer 中的文本样式务必保证和 Caption 中的一致；
                tailer: widget.isShowUploadTs ? uploadTsDisplayText(post) : null
              ),
          )
        ],
      ),
    );
  }

  rightPanel(Post post, BuildContext context) {
    /// Container 是蒙版，避免因为贴文太白导致控制面板看不清
    return Container(
      width: sp(50),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerRight,
          end: Alignment.centerLeft,
          colors: <Color>[
            Colors.black12.withOpacity(0.2),
            Colors.black12.withOpacity(0.1)
          ]
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(
          children: [
            StatefulLikeButton(post: post),
            SizedBox(height: sp(26)),
            StatefulFavoriteButton(post: post),
            SizedBox(height: sp(26)),
            ... _unSeenPostButton(post, context),
            ... _downloadButton(post),
            if ((AppServiceManager.appConfig.display as HBaseDisplay).showJubao)
              const JuBao()

          ],
        ),
      ),
    );
  }

  /// 因为这个组件的展示是可配置的，因此只有在展示它的时候才需要显示 padding bottom，因此将 padding bottom
  /// 写在组件一起；
  List<Widget> _downloadButton(Post post) {
    var user = HBaseUserService.user;
    /// 注意，分解出 [isUnlockPicDownload] 只是为了 chk，chk 模式下只能下载图片，为了更简化就直接只能下载单图，
    /// 在 chk 的时候，第一页应该要能够插入一些单图便于chk（可以硬插），因此下面的逻辑有点怪怪的，都是为了方便 chk
    if (
        ((post.type == PostType.photo || post.type == PostType.picAlbum) && user.isShowPicDownload) || 
        ((post.type == PostType.video || post.type == PostType.videoAlbum) && user.isShowVideoDownload) 
    ) {
      return [
        GestureDetector(
          onTap: () async {
            await DownloadService.downloadChoice(context, post);
          },
          child: Column(
            children: [
              Icon(Ionicons.cloud_download_outline, size: sp(30),),
              SizedBox(height: sp(4)),
              Text('下载', style: TextStyle(fontSize: sp(14))),
            ],
          ),
        ),
        SizedBox(height: sp(26))
      ];
    }
    return [Container()];
  }

  /// 使用 maxWidth 来控制 profile name 避免越界
  _profileName(Post post) => ConstrainedBox(
    constraints: BoxConstraints(maxWidth: sp(160.0)),
    child: Text(
      post.profile.name,
      style: TextStyle(fontSize: sp(16), fontWeight: FontWeight.bold, color: Colors.white),
      overflow: TextOverflow.ellipsis,
    ),
  );    
  

  _followButton(Post post, BuildContext context) {
    return StatefulFollowButton(
      profile: post.profile,
      followButtonCreator: ({required bool loading, required onTap}) =>
        TextButton(
          onPressed: () => onTap(context), 
          style: TextButton.styleFrom(
            /// 注意，下面三个参数是用来设置 TextButton 的内部 padding 的，默认的值比较大
            /// 参考 https://stackoverflow.com/questions/66291836/flutter-textbutton-remove-padding-and-inner-padding
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            padding: EdgeInsets.zero,
            minimumSize: Size(sp(50), sp(30)),  // 重要：定义按钮的大小
            /// 设置 text button 的 border                          
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0), // Adjust border radius as needed
              side: const BorderSide(
                color: Colors.white, // Color of the border
                width: 1.0, // Width of the border
              ),
            ),
            backgroundColor: Colors.black12.withOpacity(0.1)
          ),
          child: loading 
            ? SizedBox(width: sp(14), height: sp(14), child: const CircularProgressIndicator(strokeWidth: 1.5, color: Colors.white54))
            : Text('关注', style: TextStyle(fontSize: sp(14), fontWeight: FontWeight.bold, color: Colors.white)),
        ),
      cancelFollowButtonCreator: ({required bool loading, required onTap}) => 
        TextButton(
          onPressed: () => onTap(context), 
          style: TextButton.styleFrom(
            /// 注意，下面三个参数是用来设置 TextButton 的内部 padding 的，默认的值比较大
            /// 参考 https://stackoverflow.com/questions/66291836/flutter-textbutton-remove-padding-and-inner-padding
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            padding: EdgeInsets.zero,
            minimumSize: Size(sp(50), sp(30)),  // 重要：定义按钮的大小
            /// 设置 text button 的 border                          
            backgroundColor: Colors.black12.withOpacity(0.1)
          ),
          child: loading 
            ? SizedBox(width: sp(14), height: sp(14), child: const CircularProgressIndicator(strokeWidth: 1.5, color: Colors.white54))
            : Text('已关注', style: TextStyle(fontSize: sp(14), color: Colors.white54)),
        ),
    );
  }

  /// 屏蔽此贴文
  _unSeenPostButton(Post post, BuildContext context) {
    return [
      GestureDetector(
        onTap: () async {
          var isConfirmed = await showConfirmDialogWithoutContext(
            content: '是否屏蔽此帖文', 
            confirmBtnTxt: '确定', 
            cancelBtnTxt: '不了');
          if (isConfirmed) {
            GlobalLoading.show('屏蔽中，请稍后...');
            Timer(Duration(milliseconds: Random.randomInt(800, 2800)), () async {
              HBaseStateService.triggerUnseenPostEvent(post);
              GlobalLoading.close();
              showInfoToast(msg: '已屏蔽', location: ToastLocation.CENTER);
            });
          }
        },
        child: Column(
          children: [
            Icon(Ionicons.eye_off_outline, size: sp(28),),
            SizedBox(height: sp(4)),
            Text('屏蔽', style: TextStyle(fontSize: sp(14))),
          ],
        ),
      ),
      SizedBox(height: sp(26))
    ];
  }

  @Deprecated('已经被 {PostCarouselService.imageCreator} 方法所取代')
  Widget _imgCreator(String url, double width, double aspectRatio) {
    var user = HBaseUserService.user;
    if (!user.isUnlockBlur && widget.post.blurType == BlurType.blur) {
        return BlurrableImage(
          blurDepth: widget.post.blurDepth,
          onTap: () => Get.to(() => SalePage(
            saleGroups: AppServiceManager.appConfig.saleGroups,
            initialSaleGroupType: SaleGroupType.subscr,
            backgroundImage: (AppServiceManager.appConfig as HBaseAppConfig).salePageBackgroundImage,
          )),
          unlockButtonColor: AppServiceManager.appConfig.appTheme.seedColor,
          child: CachedImage(width: width, imgUrl: url, aspectRatio: aspectRatio,),
        );
    } else {
      return CachedImage(width: width, imgUrl: url, aspectRatio: aspectRatio,);
    }
  }

  @Deprecated('已经被 {PostCarouselService.videoCreator} 方法所取代')
  // ignore: unused_element  
  Widget _videoCreator(String videoUrl, String coverImgUrl, double width, double aspectRatio, BoxFit fit) {
    var user = HBaseUserService.user;
    if (!user.isUnlockBlur && widget.post.blurType == BlurType.blur) {
      return BlurrableVideoPlayer(
        width: width, 
        aspectRatio: aspectRatio,
        videoUrl: videoUrl,
        coverImgUrl: coverImgUrl,
        blurDepth: widget.post.blurDepth, 
        // fit: fit,
        // 默认情况下如果是单 reel 为了让 reel 能够撑满整个屏幕，回调的是 BoxFit.cover，但是正如 [Carousel] 注解中所提到的那样，
        // BoxFit.cover 虽然会撑满整个屏幕但是代价是 reel 会延伸到屏幕之外且试过裁剪，但是在目前 Carousel 的实现下，任何裁剪都是
        // 无效的；因此默认这里返回的是 BoxFit.cover，单它会导致一个问题就是在横向 tab 页面之间切换的时候，比如从"推荐"切换到"欧美"
        // 的过程中，会导致边缘被看到，因为 blur 只会 blur 屏幕内可视部分，超出屏幕部分的无法 blur；因此为了能够实现在任何情况下都
        // 彻底 blur，因此这里将 fit 硬编码维 BoxFit.contain，这样就不会出现上面的问题了。
        fit: BoxFit.contain,
        unlockButtonColor: AppServiceManager.appConfig.appTheme.seedColor,
        onTap: () => Get.to(() => SalePage(
          saleGroups: AppServiceManager.appConfig.saleGroups,
          initialSaleGroupType: SaleGroupType.subscr,
          backgroundImage: (AppServiceManager.appConfig as HBaseAppConfig).salePageBackgroundImage,
        )),
      );
    } else if (!user.isUnlockBlur && widget.post.blurType == BlurType.limitPlay) {
      return DurationLimitableVideoPlayer(
        width: width, 
        aspectRatio: aspectRatio,
        videoUrl: videoUrl, 
        unlockButtonColor: AppServiceManager.appConfig.appTheme.seedColor,
        onTap: () => Get.to(() => SalePage(
          saleGroups: AppServiceManager.appConfig.saleGroups,
          initialSaleGroupType: SaleGroupType.subscr,
          backgroundImage: (AppServiceManager.appConfig as HBaseAppConfig).salePageBackgroundImage,
        ))
      );      
    } else {
      return CachedVideoPlayer(
        width: width, 
        aspectRatio: aspectRatio,
        videoUrl: videoUrl,
        coverImgUrl: coverImgUrl,
        fit: fit,
      );      
    }
  }

  /// 用户在 [PostFullScreenView] 页面发生 userStay 后的回调方法
  userStayCallback() async {
    debugPrint('$PostFullScreenListView.userStayed calls for post ${widget.post.shortcode}');
    // save viewhis
    await HBaseUserService.saveViewHis(widget.post.shortcode);
    // 教学内容展示
    // 必须保证在 unlock blur 的前提下提示进入博主空间
    if (HBaseUserService.user.isUnlockBlur) {
      isShowEnterProfileTooltip.value = true;
    }
  }

  /// 之前试图通过 GlobalKey 的方式来检测是否可见，使用了 Google 的结果，失败；也因此最后通过 GetX state 结合 [VisibilityDetector]
  /// 的方式来解决的，详情参考：[HBaseStateService.isBottomNavigationBarVisible]
  bool get isBottomNavigationBarVisible => throw Exception('unImplemented');

  /// 注意，返回的 offsetTop 是以左上角开始即 (0,0) 开始
  double get bottomNavigationBarOffsetTop {
    /// 只要 BottomNavigationBar 在 tree 中无论是否可见，[bottomNavigationBarKey.currentContext] 都不会返回 null
    if (bottomNavigationBarKey.currentContext != null) {
      final RenderBox renderBox = bottomNavigationBarKey.currentContext!.findRenderObject() as RenderBox;
      final Offset globalPosition = renderBox.localToGlobal(Offset.zero);

      // globalPosition.dx and globalPosition.dy will give you the x and y coordinates
      // of the top-left corner of the widget relative to the screen.
      debugPrint('bottomAppBarKey Global Position: $globalPosition, screen height: ${Screen.height(context)}');
      return globalPosition.dy;
    }
    throw Exception('bottomAppBarOffsetTop is not in the tree which means it is not used in current page');
  }

  /// 正如 [HBaseStateService.isBottomNavigationBarVisible] 中所描述的那样，因为可见性是通过 [VisibilityDetector] 来控制的
  /// 这是有延迟的，因此如果没有延时展示机制的话，会先看到控制面板开始定位偏离，稍后可以被 Obx 修正。
  double get offsetBottom => HBaseStateService.isBottomNavigationBarVisible() 
    ? (Screen.height(context) - bottomNavigationBarOffsetTop) // 结果是 bottom appbar offset bottom
      // 在模拟器上测试 SE 小屏幕下要偏移 20 否则和 bottom appbar 边缘有重叠，可能是像素计算方式的问题导致的，微调一下
      + (Device.isSmallSizeScreen(context) ? 20.0 : 16.0)  
    : 34.0; 

  /// 逻辑非常的简单，休眠 3 秒钟后，将 unBlur 的权限注入即可；此时通过 GetX 的状态更新即可更新界面
  // ignore: unused_element
  _mockToUnlockBlur() {
    showInfoToast(msg: 'unlock blur will happened soon');
    Timer(const Duration(seconds: 3), () {
      var userStateMgr = Get.find<UserStateManager>();
      var user = userStateMgr.user; 
      /// 使用 [UserStateManager.refresh] 方法更新整个 user 也是可以的，参考 [ResponseHandler.parseUser] 中
      /// 的 UserService.syncUserState 执行逻辑
      user.update((user) {
        /// 这里是关键扩展点，将 user 映射为子系统的 User，这样就可以对它进行响应式编程了
        var localUser = user! as HBaseUser;
        localUser.authorities.addIf(!localUser.authorities.contains(UserAuthority.unlockBlur), UserAuthority.unlockBlur);
        debugPrint('unlockBlur authority has been added to user');
      });                 
    });
  }

  Widget uploadTsDisplayText(Post post) =>
    Text(
      (AppServiceManager.appConfig.display as HBaseDisplay).uploadTsDisplayMode == UploadTsDisplayMode.datetime
      ? DateFormat('yyyy-MM-dd HH:mm').format(post.uploadTs.toLocal())
      /// 1. 需要注意的是 GetTimeAgo 是按照 UTC 时间来比对的，因此下面的转换千万不要使用 .toLocal 转换成本地时间呢
      /// 2. 如果时间超过一段时间了，就不会一 time ago 的方式展示了，估计 3、5 个月之前的吧，他会按照 [pattern] 所制定的格式展示了
      /// 3. 如果设置 DateTime.now 之后的时间，不会显示刚刚，算法是：我猜测 GetTimeAgo 取的是绝对值，因为如果往后设置 2 个小时，显
      ///    示 2 个小时前；因此最好不要像火酷那样提前预置 1 个小时，使得发布的内容可以提前一个小时展示“刚刚“
      : GetTimeAgo.parse(post.uploadTs, locale: 'zh', pattern: 'yyyy-MM-dd HH:mm'),
      /// 注意样式必须和 Caption 中的字体样式保持一致
      style: TextStyle(
        fontSize: sp(14), 
        color: Colors.white)
    );

}
