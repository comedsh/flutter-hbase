import 'package:appbase/appbase.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sycomponents/components.dart';

/// 将一些页面上会共用到的业务逻辑放到这里
class PageService {

  static zhuxiao({
    String warningMsg = '注销账户后，你的所有数据将会被清除，确定注销账户？',
  }) async {
    var isConfirmed = await showConfirmDialogWithoutContext(
      title: '警告',
      content: warningMsg,
      confirmBtnTxt: '确定',
      cancelBtnTxt: '不了'
    );
    if (isConfirmed) {
      GlobalLoading.show();
      try {
        await dio.post('/u/zhuxiao');
        GlobalLoading.close();
        await showAlertDialogWithoutContext(
          content: '账户已注销',
          confirmBtnTxt: '好的'
        );
        // 只在前端清空用户的订阅、积分等信息          
        var userStateMgr = Get.find<UserStateManager>();
        var user = userStateMgr.user; 
        user.update((user) {
          user!.subscr = null;
          user.point = Point(hasPurchasedPoint: false, remainPoints: 0);
        });                                       
      } catch(e, stacktrace) {
        debugPrint('user logout get error: $e, stacktrace: $stacktrace');
        GlobalLoading.close();
        showErrorToast(msg: '网络异常，请稍后再试');
      }
    }
  }

}