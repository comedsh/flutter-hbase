// ignore_for_file: depend_on_referenced_packages

import 'package:adjiang/src/pages/myspace/user_profile/user_profile_editor/service/avatar_upload_service.dart';
import 'package:flutter/material.dart';
import 'package:appbase/appbase.dart';
import 'package:sycomponents/components.dart';
import 'package:get/get.dart';

import '../../../../../domain/user/user.dart';
import '../../../myspace_page.dart';

class UserProfileAvatarEditorView extends StatefulWidget {
  const UserProfileAvatarEditorView({super.key});

  @override
  State<UserProfileAvatarEditorView> createState() => _UserProfileAvatarEditorViewState();
}

class _UserProfileAvatarEditorViewState extends State<UserProfileAvatarEditorView> {
  @override
  Widget build(BuildContext context) {

    return GestureDetector(
      onTap: chooseAndUploadAvatar,
      child: Obx(() => Column(
        children: [
          (UserService.user as AdJiangUser).avatarUrl == null 
          ? SyCircleAvatar(width: avatarSize, image: const Image(image: AssetImage("images/anonymous_user_avatar.png")), borderColor: Colors.white, borderWidth: 2.0)
          : SyCircleAvatar(width: avatarSize, imgUrl: (UserService.user as AdJiangUser).avatarUrl, borderColor: Colors.white, borderWidth: 2.0),
          TextButton(onPressed: chooseAndUploadAvatar, child: const Text('更换头像'))
        ],
      )),
    );
  }

  chooseAndUploadAvatar() async {
    var avatarPath = await AvatarUploadService.picUpAvatarImg();
    if (avatarPath != null) {
      GlobalLoading.show('上传中，请稍后...');
      try {
        await AvatarUploadService.uploadAvatar(avatarPath);
      } catch(e, stacktrace) {
        debugPrint('when upload avatar, $e, $stacktrace');
        showErrorToast(msg: '网络异常，请稍后再试');
      } finally {
        GlobalLoading.close();
      }
    }
  }

  double get maxWidth => Screen.widthWithoutContext() - MyspacePage.horizontalPaddingSize * 2;
  /// 头像的 width 和 [UserProfileView] 中的保持一致
  double get avatarSize => maxWidth / 4;  
}