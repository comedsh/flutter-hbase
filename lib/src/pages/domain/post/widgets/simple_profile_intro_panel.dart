
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hbase/hbase.dart';
import 'package:sycomponents/components.dart';

class SimplePorifleIntroPanel extends StatelessWidget {
  /// 该参数是保持 [PostFullScreenView] 中所需要的逻辑，为将来重构保留原有逻辑。
  final int postIndex;
  final Post post;

  /// 头像、名字、关注三件套构成一个最简单的 profile intro panel；之所以放在 post domain 中是因为该组件
  /// 仅会被 Post 相关组件所调用；
  /// 
  /// 该组件重构自 [PostFullScreenView]，但是并没有替换该组件的代码，因为被一个参数 isShowEnterProfileTooltip
  /// 所困住了，该参数是在发生了 userStay 事件后才显示 tooltip 是和 [PostFullScreenView] 强耦合的，现在重构
  /// 它的成本有些高，如果单单是为了 [HotspotPostCardSwiperView] 复用而去重构它在现阶段不划算... 因此你会发现，
  /// 下面的代码和 [PostFullScreenView] 中的代码高度重合也不要奇怪！
  /// 
  const SimplePorifleIntroPanel({
    super.key, 
    required this.postIndex, 
    required this.post
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ProfileAvatar(
          profile: post.profile, 
          size: sp(44), 
          /// 为了避免陷入无限的 profile -> post page -> profile -> post page ... 这样的链条中，
          /// 如果当前是从 ProfilePage 中跳转的，那么当点击头像的时候，是回退操作即回退到 profile page，
          /// 这样就可以有效的阻断上述的无限链条... 
          onTap: () { 
            Get.previousRoute == "/$ProfilePage"
              ? Get.back<int>(result: postIndex)
              : Get.to(() => ProfilePage(profile: post.profile));
            ScoreService.notifyScoreSimple();
          },
        ),
        // profile name
        GestureDetector(
          /// 注释同上
          onTap: () { 
            Get.previousRoute == "/$ProfilePage"
              ? Get.back<int>(result: postIndex)
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
              child: Text(
                post.profile.name, 
                style: TextStyle(fontSize: sp(16), fontWeight: FontWeight.bold, color: Colors.white),
              ),
            )
          ),
        ),
        // follow button
        followButton(post, context),
      ],
    );
  }

  followButton(Post post, BuildContext context) {
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

}