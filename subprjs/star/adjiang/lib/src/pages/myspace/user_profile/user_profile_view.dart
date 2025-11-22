
// ignore_for_file: depend_on_referenced_packages

import 'package:adjiang/src/pages/myspace/myspace_page.dart';
import 'package:adjiang/src/pages/myspace/user_profile/user_profile_editor/user_profile_editor_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:appbase/appbase.dart';
import 'package:hbase/hbase.dart';
import 'package:sycomponents/components.dart';
import 'package:ionicons/ionicons.dart';

import '../../../domain/user/adjiang_user.dart';

class UserProfileView extends StatefulWidget {
  const UserProfileView({super.key});

  @override
  State<UserProfileView> createState() => _UserProfileViewState();
}

class _UserProfileViewState extends State<UserProfileView> {

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: () => Get.to(() => const UserProfileEditorPage()),
          /// 在 iPad 小屏幕上依旧会溢出，因此最好是加上 scroll 以完全杜绝
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                // ✅✅avatar
                Obx(() =>
                  (UserService.user as AdJiangUser).avatarUrl == null 
                  ? SyCircleAvatar(width: avatarSize, image: const Image(image: AssetImage("images/anonymous_user_avatar.png")), borderColor: Colors.white, borderWidth: 2.0)
                  : SyCircleAvatar(width: avatarSize, imgUrl: (UserService.user as AdJiangUser).avatarUrl, borderColor: Colors.white, borderWidth: 2.0),
                ),
                SizedBox(width: sp(22)),
                // ✅✅introduce
                Obx(() => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: sp(210),
                      child: Text(
                        (UserService.user as AdJiangUser).username, 
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: sp(24))
                      ),
                    ),
                    SizedBox(height: sp(4)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Column(children: [
                          Text('喜欢过', style: TextStyle(fontSize: itemTextSize)),
                          Text(compactFormat.format((UserService.user as AdJiangUser).likeCount), style: TextStyle(fontSize: itemNumSize)),
                        ]),
                        SizedBox(width: itemGapSize),
                        /// 关注后粉丝数应该同步 +1，但是因为现在粉丝数并不会精确到个位，因此没有必要
                        Column(children: [
                          Text('收藏过', style: TextStyle(fontSize: itemTextSize)),
                          Text(compactFormat.format((UserService.user as AdJiangUser).favoriteCount), style: TextStyle(fontSize: itemNumSize)),
                        ]),
                        SizedBox(width: itemGapSize),
                        Column(children: [
                          Text('关注过', style: TextStyle(fontSize: itemTextSize)),
                          Text(compactFormat.format((UserService.user as AdJiangUser).followCount), style: TextStyle(fontSize: itemNumSize)),
                        ]),
                      ],
                    )
                  ],
                )),
                SizedBox(width: sp(42)),
                Icon(Ionicons.chevron_forward_outline, size: sp(38),)
              ],
            ),
          ),
        ),
        // ✅✅个性签名
        Row(
          children: [
            Padding(
              padding: EdgeInsets.only(left: sp(6), right: sp(6), top: sp(12)),
              child: SizedBox(
                width: Screen.width(context) * 0.85,
                child: Obx(() => Text(
                  (UserService.user as AdJiangUser).signature == null || (UserService.user as AdJiangUser).signature!.trim() == "" 
                  ? '还没有个性签名哦...'
                  : (UserService.user as AdJiangUser).signature!, 
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Theme.of(context).hintColor)
                )),
              ),
            )
          ],
        )
      ],
    );
  }



  double get maxWidth => Screen.widthWithoutContext() - MyspacePage.horizontalPaddingSize * 2;
  double get avatarSize => maxWidth / 4;
  double get itemGapSize => maxWidth / 10;
  double get itemTextSize => sp(13);
  double get itemNumSize => sp(16);
}