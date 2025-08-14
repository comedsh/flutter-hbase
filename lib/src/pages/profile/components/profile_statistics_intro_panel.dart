import 'package:appbase/appbase.dart';
import 'package:flutter/material.dart';
import 'package:hbase/hbase.dart';
import 'package:sycomponents/components.dart';


/// 就是 Profile 页面的上半部分
class ProfileStatisticsIntroPanel extends StatelessWidget {
  final Profile profile;
  
  const ProfileStatisticsIntroPanel({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    final paddingSize = sp(12.0);
    return Padding(
      padding: EdgeInsets.all(sp(paddingSize)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// 头像、帖子数... + 关注按钮
          Row(
            children: [
              /// 注意，ProfileAvatar 内部使用的是 [SyCircleAvatar]，构建它的时候必须指定 height 和 width，
              /// 否则 NestedScrollView 布局报错，正是因为必须指定 avatar 的大小，这里就设定为屏幕宽度的 1/3 
              /// 且减去 20 个像素的这样一个安全值（20 是一个安全值）；
              ProfileAvatar(profile: profile, size: Screen.width(context) / 3 - sp(20)),
              SizedBox(width: sp(20)),
              /// 如果要让内部的 Column/Row 占满外部 Column/Row 空间，可以使用 Expanded
              Expanded(
                child: Column(
                  children: [
                    statisticPanel(context, profile),
                    SizedBox(height: sp(12)),
                    followButton(context, profile)
                  ],
                ),
              )
            ],
          ),
          SizedBox(height: sp(8)),
          description(context, profile, paddingSize)
        ],
      ),
    );
  }

  /// 注意，构建 [SyCircleAvatar] 的时候必须指定 height 和 width，否则 NestedScrollView 布局报错
  /// 正是因为必须指定 avatar 的大小，这里就设定为屏幕宽度的 1/3 且减去 20 个像素的这样一个安全值
  avatar(BuildContext context, Profile profile) {
    final avatarSize = Screen.width(context) / 3 - sp(20);
    return SyCircleAvatar(
      imgUrl: profile.avatar,
      width: avatarSize,
      height: avatarSize,
    );
  }

  statisticPanel(BuildContext context, Profile profile) {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Column(children: [
          Text('帖子数'),
          Text('300')
        ]),
        Column(children: [
          Text('帖子数'),
          Text('300')
        ]),
        Column(children: [
          Text('帖子数'),
          Text('300')
        ]),
      ],
    );
  }

  followButton(BuildContext context, Profile profile) {
    return GradientElevatedButton(
      gradient: LinearGradient(colors: [
        AppServiceManager.appConfig.appTheme.fillGradientStartColor,
        AppServiceManager.appConfig.appTheme.fillGradientEndColor
      ]),
      width: Screen.width(context) * 0.56,
      height: sp(42.0),
      borderRadius: BorderRadius.circular(30.0),
      onPressed: () {
      },
      child: Text('关注', style: TextStyle(color: Colors.white, fontSize: sp(18), fontWeight: FontWeight.bold),)
    );
  }

  description(BuildContext context, Profile profile, double paddingSize) {
    return Center(
      child: ExpandableText(
        minLines: 3,
        maxLines: 5, 
        maxWidth: Screen.width(context) - 2 * paddingSize,
        // text:"To display a scrollbar for a SingleChildScrollView in Flutter, you need to wrap the SingleChildScrollView widget within a Scrollbar widget."
        //  "To display a scrollbar for a SingleChildScrollView in Flutter, you need to wrap the SingleChildScrollView widget within a Scrollbar widget.",
        text: profile.description ?? "",
        style: TextStyle(fontSize: sp(16.0), height: 1.5)
      ),
    );
  }

}