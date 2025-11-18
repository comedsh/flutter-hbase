// ignore_for_file: depend_on_referenced_packages
import 'package:get/get.dart' hide FormData, MultipartFile;

import 'package:flutter/material.dart';
import 'package:appbase/appbase.dart';
import 'package:sycomponents/components.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AvatarUploadService {

  static Future<String?> picUpAvatarImg() async {
    // 该 loading 是应对第一次打开相册过慢的问题
    GlobalLoading.show();

    await 1.2.delay();  // 打开相机会卡顿，导致 loading 未展示，先休眠一小会儿

    try {
      // 检查是否有相机/相册的访问权限
      var hasPermission = await DevicePermission.isPhotoAccessableWithQuickGrantIfNot(
        appName: AppServiceManager.appConfig.appName, 
        reason: "以便你可以从相册中选择图片来上传头像"
      );

      if (!hasPermission) {
        // GlobalLoading.close();  // 由 finally 控制关闭
        return null;
      }

      final XFile? image = await ImagePicker().pickImage(source: ImageSource.gallery);
      debugPrint('XFile image ${image?.path ?? 'path not exits'} has been selected');          
      var imgPath = image?.path;

      // 如果 image picker 用户选择了放弃，直接返回
      if (imgPath == null) {
        // GlobalLoading.close();  // 由 finally 控制关闭
        return null;
      }

      var jpgPath = await ImageConverter.convertToJPG(imgPath);

      // 不知道为什么，打开 crop 界面总是会卡顿一下
      var croppedImgPath = await StandardImageCropper.start(imageAbsolutePath: jpgPath, title: "图片裁剪（单指可拖拽，双指可放大）");
      // 如果用户在裁剪的时候放弃，那么直接返回
      if (croppedImgPath == null) {
        return null;        
      }

      String? compressedImgPath = await ImageCompression.compressToTargetSize(
          imageFileAbsolutePath: croppedImgPath,
          targetSize: 1000 * 80  // 80K
      );

      // the final gurantee sir. 
      // 确保传递给 [GoogleFaceDetector] 的一定是 JPEG 格式的图片
      assert(['.jpg', '.jpeg'].contains(FileUtils.extension(compressedImgPath!)), 
        'compressedImagePath ${FileUtils.basename(compressedImgPath)} is NOT a JPG/JPEG file, this should not happen');

      return compressedImgPath;

    } finally {

      GlobalLoading.close();
    }

  }

  static uploadAvatar(String filePath) async {
    try {
      debugPrint('uploading the avatar: ${FileUtils.basename(filePath)}');
      var formData = FormData.fromMap({
        // 特别注意，
        // 1. 这里的属性名 `avatar` 必须和后台的属性名 `avatar` 相匹配，否则无法解析此上传文件
        // 2. filename 必须填写后缀名，因为后台 multer 解析的时候只能通过 filename 解析到文件后缀名
        'avatar': await MultipartFile.fromFile(
          filePath, 
          filename: 'avatar${FileUtils.extension(filePath)}'
        ),
      });
      /// API_POST_USER_AVATAR_UPLOAD -> /u/avatar/upload
      await dio.post(dotenv.env['API_POST_USER_AVATAR_UPLOAD']!, data: formData);
      debugPrint('$uploadAvatar, the avatar ${FileUtils.basename(filePath)} has been uploaded');
    } on Exception {
      showErrorToast(msg: '网络异常，请稍后再试');
      rethrow;
    }
  }

}