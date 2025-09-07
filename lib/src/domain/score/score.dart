import 'dart:async';

import 'package:appbase/appbase.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hbase/hbase.dart';
import 'package:sycomponents/components.dart';

class ScoreStateManager extends GetxService {
  Rx<int> scoreSimple = 0.obs;
  Rx<int> scoreTarget = 0.obs;

  updateScoreSimple() {
    scoreSimple.value = DateTime.now().millisecond;
  }

  increaseScoreTarget() {
    scoreTarget.value = scoreTarget.value + 1;
  }
}

class ScoreService {
  
  static listen() {
    final scoreState = Get.find<ScoreStateManager>();

    /// score simple 的算法简单粗暴，只要触发一次就诱导一次  
    ever(scoreState.scoreSimple, (_) {
      if ((AppServiceManager.appConfig.display as HBaseDisplay).enableScoreSimple) {
        Timer(const Duration(milliseconds: 1000), () => Rating.openRating());
      }
    });

    /// score target 的算法要复杂一些，当目标动作发生到了 3 次或 9 次或 18 次的时候才会触发，且要注意的是
    /// 如果诱导成功即跳转发生了，那么要符合后台的评分间隔才能继续诱导了；另外如果用户拒绝了，那么前端要锁定在
    /// 多少个 hours 内只能不要再次诱导了
    /// 另外需要特别注意的一点是，Score Target 和 Score Download 都还包含一个隐藏的条件，即该用户必须拥有
    /// 了 unlockBlur 的权限，这个由后台进行判断
    ever(scoreState.scoreTarget, (int val) {
      // if ([3, 9, 18].contains(val)){
      // }
      // debugPrint('scoreState.scoreTarget: $val');
      // debugPrint('enableScoreTarget: ${(AppServiceManager.appConfig.display as HBaseDisplay).enableScoreTarget}');
      if ((AppServiceManager.appConfig.display as HBaseDisplay).enableScoreTarget) {
        ScoreTargetWidget.showFirst();
      }
    });
  }

  static notifyScoreSimple() {
    ScoreStateManager ssm = Get.find();
    ssm.updateScoreSimple();
  }

  static increaseScoreTarget() {
    ScoreStateManager ssm = Get.find();
    ssm.increaseScoreTarget();
  }
}

class ScoreTargetWidget {

  static showFirst() {
    Get.bottomSheet(
      SizedBox(
        height: sp(200),
        width: Screen.widthWithoutContext(),
        child: Card(child: 
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('您认为${AppServiceManager.appConfig.appName}怎么样？', style: TextStyle(fontSize: sp(18))),
              SizedBox(height: sp(40)),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  /// 不怎么样按钮
                  TextButton(
                    onPressed: () => Get.back(),   // 关闭窗口
                    style: TextButton.styleFrom(
                      /// 注意，下面三个参数是用来设置 TextButton 的内部 padding 的，默认的值比较大
                      /// 参考 https://stackoverflow.com/questions/66291836/flutter-textbutton-remove-padding-and-inner-padding
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      padding: EdgeInsets.zero,
                      minimumSize: Size(sp(80), sp(32)),  // 重要：定义按钮的大小
                      /// 设置 text button 的 border                          
                      backgroundColor: Colors.black12.withOpacity(0.1)
                    ),
                    child: Text('不怎样', style: TextStyle(fontSize: sp(16)))
                  ),
                  SizedBox(width: sp(30)),
                  /// 还不错按钮
                  GradientElevatedButton(
                    gradient: LinearGradient(colors: [
                      AppServiceManager.appConfig.appTheme.fillGradientEndColor,
                      AppServiceManager.appConfig.appTheme.fillGradientEndColor
                    ]),
                    width: sp(98),
                    height: sp(32.0),
                    borderRadius: BorderRadius.circular(13.0),
                    onPressed: () {
                      Get.back();
                      ScoreTargetWidget.showSecond();
                    },
                    child: Text('还不错', style: TextStyle(fontSize: sp(16)))
                  )
                ],             
              ),
            ]
        ),)
      )
    );
  }

  /// 开始诱导打分了
  static showSecond() {
    Get.bottomSheet(
      SizedBox(
        height: sp(200),
        width: Screen.widthWithoutContext(),
        child: Card(child: 
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('如果您觉得还不错，请为我们打分吧？', style: TextStyle(fontSize: sp(18))),
              SizedBox(height: sp(40)),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  /// 不怎么样按钮
                  TextButton(
                    onPressed: () => Get.back(),   // 关闭窗口
                    style: TextButton.styleFrom(
                      /// 注意，下面三个参数是用来设置 TextButton 的内部 padding 的，默认的值比较大
                      /// 参考 https://stackoverflow.com/questions/66291836/flutter-textbutton-remove-padding-and-inner-padding
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      padding: EdgeInsets.zero,
                      minimumSize: Size(sp(80), sp(32)),  // 重要：定义按钮的大小
                      /// 设置 text button 的 border                          
                      backgroundColor: Colors.black12.withOpacity(0.1)
                    ),
                    child: Text('不了', style: TextStyle(fontSize: sp(16)))
                  ),
                  SizedBox(width: sp(30)),
                  /// 还不错按钮
                  GradientElevatedButton(
                    gradient: LinearGradient(colors: [
                      AppServiceManager.appConfig.appTheme.fillGradientEndColor,
                      AppServiceManager.appConfig.appTheme.fillGradientEndColor
                    ]),
                    width: sp(98),
                    height: sp(32.0),
                    borderRadius: BorderRadius.circular(13.0),
                    onPressed: () {
                      Rating.openStoreListing(AppServiceManager.appConfig.appStoreId);
                      /// TODO record 诱导记录
                    },
                    child: Text('当然', style: TextStyle(fontSize: sp(16)))
                  )
                ],             
              ),
            ]
        ),)
      )
    );
  }

}