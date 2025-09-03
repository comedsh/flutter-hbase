
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hbase/hbase.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:ionicons/ionicons.dart';
import 'package:sycomponents/components.dart';


final compactFormat = NumberFormat.compact(locale: 'zh_CN');


/// 这是一个满屏展示的 post 页面，实现主要是参考 ins 页面的设计；且因为该组件只是提供给 HBase 系统使用，
/// 因此它的实现粒度范围就围绕着 HBase 系统的需要展开，比如包含喜欢、收藏、关注、下载逻辑等等；然而之所以
/// 将其定义为抽象类是让子系统可以按照自己的需求对某些功能进行定制，比如下载行为等等；
/// 
class PostFullScreenView extends StatelessWidget{
  final Post post;
  /// 通常 [PostFullScreenView] 是在列表中展示，这里的 [postIndex] 即表示该 post 在此列表中的下标
  final int postIndex;

  const PostFullScreenView({
    super.key, 
    required this.post,
    required this.postIndex
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Container(
            alignment: Alignment.center,
            child: createPostPage(context)
          ),
        ),
      ],
    );
  }

  createPostPage(BuildContext context) {
    return Stack(
      children: [
        AutoKnockDoorShowCaseCarousel(
          slots: post.slots, 
          indicatorPaddingBottom: 10, 
          imageCreator: (String url, double width, double aspectRatio) => 
            _imgCreator(url, width, aspectRatio),
          videoCreator: (String videoUrl, String coverImgUrl, double width, double aspectRatio, BoxFit fit) =>
            _videoCreator(videoUrl, coverImgUrl, width, aspectRatio, fit)
        ),
        Positioned(
          bottom: sp(42),
          left: sp(20),
          child: leftPanel(post, context)
        ),
        Positioned(
          bottom: sp(42),
          right: sp(20),
          child: rightPanel(post, context)
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
                onTap: () => Get.previousRoute == "/$ProfilePage"
                ? Get.back<int>(result: postIndex)
                : Get.to(() => ProfilePage(profile: post.profile)),
              ),
              // profile name
              GestureDetector(
                /// 注释同上
                onTap: () => Get.previousRoute == "/$ProfilePage"
                  ? Get.back<int>(result: postIndex)
                  : Get.to(() => ProfilePage(profile: post.profile)),
                child: Padding(
                  padding: EdgeInsets.only(left: sp(8.0)),
                  child: Text(post.profile.name, style: TextStyle(fontSize: sp(16), fontWeight: FontWeight.bold, color: Colors.white),),
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
          Caption(post: post, maxLines: 7,)
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
        _downloadButton(post)
      ],
    );
  }

  /// 将下载后的具体行为抽象出来由子类自行实现
  _downloadButton(Post post) {
    return Column(
      children: [
        Icon(Ionicons.cloud_download_outline, size: sp(30),),
        SizedBox(height: sp(4)),
        Text('下载', style: TextStyle(fontSize: sp(14))),
      ],
    );
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
    if (!user.isUnlockBlur && post.blur == BlurType.blur) {
        return BlurrableImage(
          blurDepth: post.blurDepth,
          onTap: () => showConfirmDialogWithoutContext(
            confirmBtnTxt: '确认',
            cancelBtnTxt: '不了'
          ),
          child: CachedImage(width: width, imgUrl: url, aspectRatio: aspectRatio,),
        );
    } else {
      return CachedImage(width: width, imgUrl: url, aspectRatio: aspectRatio,);
    }
  }

  Widget _videoCreator(String videoUrl, String coverImgUrl, double width, double aspectRatio, BoxFit fit) {
    var user = HBaseUserService.user;
    if (!user.isUnlockBlur && post.blur == BlurType.blur) {
      return BlurrableVideoPlayer(
        width: width, 
        aspectRatio: aspectRatio, 
        videoUrl: videoUrl,
        coverImgUrl: coverImgUrl,
        blurDepth: post.blurDepth, 
        fit: fit,
        onTap: () => showConfirmDialogWithoutContext(
          confirmBtnTxt: '确认',
          cancelBtnTxt: '不了'
        )
      );      
    } else if (!user.isUnlockBlur && post.blur == BlurType.limitPlay) {
      return DurationLimitableVideoPlayer(
        width: width, 
        aspectRatio: aspectRatio, 
        videoUrl: videoUrl, 
        onTap: () => showConfirmDialogWithoutContext(
          confirmBtnTxt: '确认',
          cancelBtnTxt: '不了'
        )
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
}
