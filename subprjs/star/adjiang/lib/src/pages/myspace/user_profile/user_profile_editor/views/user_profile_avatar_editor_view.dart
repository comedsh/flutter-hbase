import 'package:flutter/material.dart';
import 'package:sycomponents/components.dart';

import '../../../myspace_page.dart';

class UserProfileAvatarEditorView extends StatefulWidget {
  const UserProfileAvatarEditorView({super.key});

  @override
  State<UserProfileAvatarEditorView> createState() => _UserProfileAvatarEditorViewState();
}

class _UserProfileAvatarEditorViewState extends State<UserProfileAvatarEditorView> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SyCircleAvatar(
          width: avatarSize,
          image: const Image(image: AssetImage("images/anonymous_user_avatar.png")),
          borderColor: Colors.white,
          borderWidth: 2.0,
        ),
        TextButton(onPressed: (){}, child: const Text('更换头像'))
      ],
    );
  }

  double get maxWidth => Screen.widthWithoutContext() - MyspacePage.horizontalPaddingSize * 2;
  /// 头像的 width 和 [UserProfileView] 中的保持一致
  double get avatarSize => maxWidth / 4;  
}