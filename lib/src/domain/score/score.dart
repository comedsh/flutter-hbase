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

  // ignore: non_constant_identifier_names
  static String LOCK_SCORE_TARGET_NAME = 'lockScoreTarget';
  // ignore: non_constant_identifier_names
  static String LOCK_SCORE_SIMPLE_NAME = 'lockScoreSimple';
  
  static listen() {
    final scoreState = Get.find<ScoreStateManager>();

    /// score simple 的算法简单粗暴，只要触发一次就诱导一次；频控通过框架自身控制即可，但要注意的是，如果 scoreTarget
    /// 已经被锁定，那么这里也不应该被展示了
    ever(scoreState.scoreSimple, (_) async {
      if (HBaseUserService.user.isUnlockScoreSimple 
        && await ScoreService.isScoreSimpleLocked() == false
        && await ScoreService.isScoreTargetLocked() == false
      ) {
        Timer(const Duration(milliseconds: 1000), () {
           Rating.openRating();
           ScoreService.lockScoreSimple();
        });
      }
    });

    /// score target 的算法要复杂一些，当目标动作发生到 [frequenceCtlArray] 中所配置的时候才会触发，且
    /// 要注意的是如果诱导成功即跳转发生了，那么要符合后台的评分间隔才能继续诱导了；另外如果用户拒绝了，那么前端
    /// 要锁定在多少个 hours 内只能不要再次诱导了
    /// 
    /// 另外需要特别注意的一点是，Score Target 和 Score Download 都还包含一个隐藏的条件，即该用户必须拥有
    /// 了 unlockBlur 的权限，这个由后台进行判断
    /// 
    /// 有关频控的说明：如果用户只是简单的关闭，那么还是会按照队列中的频次控制，但是如果一旦点击了不怎么样，或者
    /// 选择不评分，或者已经评分了，那么就要在前端上锁 24 小时；
    /// 
    ever(scoreState.scoreTarget, (int val) async {
      // debugPrint('enableScoreTarget: ${(AppServiceManager.appConfig.display as HBaseDisplay).enableScoreTarget}');
      // 下面这个队列只是为了方便测试，目的是让每次 target 事件发生的时候都会触发，这样便于测试
      // const frequenceCtlArray = [1,2,3,4,5,6,7,8,9,10];
      const frequenceCtlArray = [3, 9, 21];     
      if (frequenceCtlArray.contains(val)){
        if (HBaseUserService.user.isUnlockScoreTarget && await ScoreService.isScoreTargetLocked() == false) {
          ScoreTargetWidget.showFirst();
        }
      }

    });

  }

  /// 发送 score simple 事件
  static notifyScoreSimple() {
    if (HBaseUserService.user.isUnlockScoreSimple) {
      ScoreStateManager ssm = Get.find();
      ssm.updateScoreSimple();
    }
  }

  /// score target 是通过相关事件发生的次数积累后才会触发的
  static increaseScoreTarget() {
    if (HBaseUserService.user.isUnlockScoreTarget) {
      ScoreStateManager ssm = Get.find();
      ssm.increaseScoreTarget();
    }
  }

  /// 唯一需要提醒的是，因为 scoreDownload 和 scoreTarget 共享后端 score 配额限制，因此 scoreDownload 的时候也
  /// 需要判断 [isScoreTargetLocked] 
  static Future<bool> isScoreTargetLocked() async {
    return await PersistentTtlLockService().isLocked(ScoreService.LOCK_SCORE_TARGET_NAME);
  }

  static Future<bool> isScoreSimpleLocked() async {
    return await PersistentTtlLockService().isLocked(ScoreService.LOCK_SCORE_SIMPLE_NAME);
  }

  /// 默认锁定一天的时间，但是如果用户明确的表明了不喜欢的话，那么要锁定更长的时间；
  static lockScoreTarget({lockSeconds = 24 * 3600}) async {
    await PersistentTtlLockService().create(
      name: ScoreService.LOCK_SCORE_TARGET_NAME, 
      expireSecs: lockSeconds
    );
  }

  static lockScoreSimple({lockSeconds = 24 * 3600}) async {
    await PersistentTtlLockService().create(
      name: ScoreService.LOCK_SCORE_SIMPLE_NAME, 
      expireSecs: lockSeconds
    );
  }

  /// 为了不阻塞跳转，不阻塞 post 请求，但随之而来的问题是 enableScoreTarget 的状态值无法得到更新，因此
  /// 借助 [ScoreService.lockScoreTarget] 来解决，详情参考该方法的实现过程
  static jumpToScore() {
    /// 这里虽然可以发起 post 请求，但是因为已经发起了跳转评分，前端是无法接收到 server response 的最新
    /// appConfDto 导致不能及时接收 enableScoreTarget 的状态值从而如果用户反复触发 score target 行
    /// 为就可以导致前端重复评分；有两种解决方案，如下，
    /// 1. 阻塞 post 请求直到其成功后才跳转评分；但是这样做的弊端是用户体验不好，如果恰好网络
    ///    延迟，那么要等待很久才会跳转评分；
    /// 2. 不阻塞 post 请求；因为这里一旦完成，前端就会对相关的操作就会被上一把锁；这样用户就无法再次发起了。
    ///    明显这个方案更好！
    dio.post('/u/tscore/save');
    Rating.openStoreListing(AppServiceManager.appConfig.appStoreId);
    Get.back();
    /// 这就是上面因为不阻塞 post 请求后跳转导致前端无法及时接收 server response 的解决方案 #2 的实现；由
    /// 前端来锁定即可；
    ScoreService.lockScoreTarget();
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
                    onPressed: () {
                      Get.back();
                      /// 因为这里用户明确的表明了不喜欢，那么锁定一个月
                      ScoreService.lockScoreTarget(lockSeconds:  30 * 24 * 3600);  
                    },   // 关闭窗口
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
              Text('如果觉得还不错，请为我们打分吧？', style: TextStyle(fontSize: sp(18))),
              SizedBox(height: sp(40)),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  /// 不了按钮
                  TextButton(
                    onPressed: () { 
                      Get.back();
                      /// 虽然这里用户选择了否定按钮，但是前面用户已经表示了肯定，因此锁定默认时长即可
                      ScoreService.lockScoreTarget();
                    },   // 关闭窗口
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
                    onPressed: () => ScoreService.jumpToScore(),
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