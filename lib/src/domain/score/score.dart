import 'dart:async';

import 'package:appbase/appbase.dart';
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
    scoreTarget.value = scoreTarget.value ++;
  }
}

class ScoreListener {
  static listen() {
    final scoreState = Get.find<ScoreStateManager>();
    ever(scoreState.scoreSimple, (_) {
      if ((AppServiceManager.appConfig.display as HBaseDisplay).enableScoreSimple) {
        Timer(const Duration(milliseconds: 1000), () => Rating.openRating());
      }
    });
  }
}

class ScoreService {
  
  static notifyScoreSimple() {
    ScoreStateManager ssm = Get.find();
    ssm.updateScoreSimple();
  }
}

