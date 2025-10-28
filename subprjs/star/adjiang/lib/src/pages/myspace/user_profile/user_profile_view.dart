
// ignore_for_file: depend_on_referenced_packages

import 'package:adjiang/src/pages/myspace/myspace_page.dart';
import 'package:flutter/material.dart';
import 'package:hbase/hbase.dart';
import 'package:sycomponents/components.dart';
import 'package:ionicons/ionicons.dart';

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
        Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            // avatar
            SyCircleAvatar(
              width: avatarSize,
              image: const Image(image: AssetImage("images/anonymous_user_avatar.png")),
              borderColor: Colors.white,
              borderWidth: 2.0,
            ),
            SizedBox(width: sp(12)),
            // introduce
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('游客', style: TextStyle(fontSize: sp(24))),
                SizedBox(height: sp(4)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Column(children: [
                      Text('喜欢过', style: TextStyle(fontSize: itemTextSize)),
                      Text(compactFormat.format(10000), style: TextStyle(fontSize: itemNumSize)),
                    ]),
                    SizedBox(width: itemGapSize),
                    /// 关注后粉丝数应该同步 +1，但是因为现在粉丝数并不会精确到个位，因此没有必要
                    Column(children: [
                      Text('收藏过', style: TextStyle(fontSize: itemTextSize)),
                      Text(compactFormat.format(1002), style: TextStyle(fontSize: itemNumSize)),
                    ]),
                    SizedBox(width: itemGapSize),
                    Column(children: [
                      Text('关注过', style: TextStyle(fontSize: itemTextSize)),
                      Text(compactFormat.format(100), style: TextStyle(fontSize: itemNumSize)),
                    ]),
                  ],
                )                
              ],
            ),
            SizedBox(width: sp(32)),
            IconButton(onPressed: null, icon: const Icon(Ionicons.chevron_forward_outline), iconSize: sp(42),),
          ],
        ),
        Row(
          children: [
            Padding(
              padding: EdgeInsets.only(left: sp(6), right: sp(6), top: sp(12)),
              child: Text('还没有个性签名哦...', style: TextStyle(color: Theme.of(context).hintColor)),
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