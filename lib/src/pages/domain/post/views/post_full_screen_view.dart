
import 'dart:async';

import 'package:appbase/appbase.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
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

  var isShowEnterProfileTooltip = false.obs;

  @override
  void initState() {
    super.initState();
    debugPrint('$PostFullScreenListView.initState calls');
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
            Obx(() => _imgCreator(url, width, aspectRatio)),
          videoCreator: (String videoUrl, String coverImgUrl, double width, double aspectRatio, BoxFit fit) =>
            Obx(() => _videoCreator(videoUrl, coverImgUrl, width, aspectRatio, fit)),
        ),
        Positioned(
          bottom: sp(42),
          left: sp(20),
          child: leftPanel(widget.post, context)
        ),
        Positioned(
          bottom: sp(42),
          right: sp(20),
          child: rightPanel(widget.post, context)
        )
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
                  padding: EdgeInsets.only(left: sp(8.0)),
                  child: Obx(() => isShowEnterProfileTooltip.value 
                    ? TooltipShowCase(
                        name: 'enterProfileTooltip',
                        tooltipText: '点击进入我的空间',
                        popupDirection: TooltipDirection.up,
                        showDurationMilsecs: 3200,
                        learnCount: 1,
                        child: Text(
                          post.profile.name, 
                          style: TextStyle(fontSize: sp(16), fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      )
                    : Text(
                        post.profile.name, 
                        style: TextStyle(fontSize: sp(16), fontWeight: FontWeight.bold, color: Colors.white),
                      ), 
                  )   
                ),
              ),
              // follow button
              Padding(
                padding: EdgeInsets.only(left: sp(8.0)),
                child: _followButton(post, context),
              ),
            ],
          ),
          SizedBox(height: sp(26)),
          /// 思路是这样的，如果用户点击展开，则 toggle 替换组件
          Caption(
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
                  saleGroups: HBaseUserService.getAvailableSaleGroups(),
                  initialSaleGroupId: SaleGroupIdEnum.subscr,
                ));
              }
            },
          )
        ],
      ),
    );
  }

  rightPanel(Post post, BuildContext context) {
    return Column(
      children: [
        StatefulLikeButton(post: post),
        SizedBox(height: sp(26)),
        StatefulFavoriteButton(post: post),
        SizedBox(height: sp(26)),
        ... _downloadButton(post),
        if ((AppServiceManager.appConfig.display as HBaseDisplay).showJubao)
          const MockJuBao()
      ],
    );
  }

  /// 因为这个组件的展示是可配置的，因此只有在展示它的时候才需要显示 padding bottom，因此将 padding bottom
  /// 写在组件一起；
  List<Widget> _downloadButton(Post post) {
    var user = HBaseUserService.user;
    /// 注意，分理出 [isUnlockPicDownload] 只是为了审核，审核员模式下只能下载图片，为了更简化就直接只能下载单图，
    /// 在审核的时候，第一页应该要能够插入一些单图便于审核（可以硬插），因此下面的逻辑有点怪怪的，都是为了方便审核
    if (post.type == PostType.photo && user.isUnlockPicDownload || 
      post.type != PostType.photo && user.isUnlockVideoDownload ) {
      return [
        Column(
          children: [
            Icon(Ionicons.cloud_download_outline, size: sp(30),),
            SizedBox(height: sp(4)),
            Text('下载', style: TextStyle(fontSize: sp(14))),
          ],
        ),
        SizedBox(height: sp(26))
      ];
    }
    return [Container()];
  }

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

  Widget _imgCreator(String url, double width, double aspectRatio) {
    var user = HBaseUserService.user;
    if (!user.isUnlockBlur && widget.post.blur == BlurType.blur) {
        return BlurrableImage(
          blurDepth: widget.post.blurDepth,
          onTap: () => Get.to(() => SalePage(
            saleGroups: HBaseUserService.getAvailableSaleGroups(),
            initialSaleGroupId: SaleGroupIdEnum.subscr,
          )),
          child: CachedImage(width: width, imgUrl: url, aspectRatio: aspectRatio,),
        );
    } else {
      return CachedImage(width: width, imgUrl: url, aspectRatio: aspectRatio,);
    }
  }

  Widget _videoCreator(String videoUrl, String coverImgUrl, double width, double aspectRatio, BoxFit fit) {
    var user = HBaseUserService.user;
    if (!user.isUnlockBlur && widget.post.blur == BlurType.blur) {
      return BlurrableVideoPlayer(
        width: width, 
        aspectRatio: aspectRatio, 
        videoUrl: videoUrl,
        coverImgUrl: coverImgUrl,
        blurDepth: widget.post.blurDepth, 
        fit: fit,
        onTap: () => Get.to(() => SalePage(
          saleGroups: HBaseUserService.getAvailableSaleGroups(),
          initialSaleGroupId: SaleGroupIdEnum.subscr,
        )),
      );
    } else if (!user.isUnlockBlur && widget.post.blur == BlurType.limitPlay) {
      return DurationLimitableVideoPlayer(
        width: width, 
        aspectRatio: aspectRatio, 
        videoUrl: videoUrl, 
        onTap: () => Get.to(() => SalePage(
          saleGroups: HBaseUserService.getAvailableSaleGroups(),
          initialSaleGroupId: SaleGroupIdEnum.subscr,
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

}

