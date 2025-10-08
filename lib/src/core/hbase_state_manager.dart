import 'package:get/get.dart';
import 'package:hbase/hbase.dart';

/// 这里定义 HBase 相关的全局的事件
/// 要激活 [HBaseStateManager] 记得一定要在子项目中的 [initSubGetxServices] 方法将其注入
class HBaseStateManager extends GetxService {
  Rx<Profile?> blockProfileEvent = Rx<Profile?>(null);
  Rx<Post?> unseenPostEvent = Rx<Post?>(null);  // unseen 译文为屏蔽，与字面意思吻合，因此取名 unseen

  updateBlockProfileEvent(Profile p) {
    blockProfileEvent.value = p;
  }

  updateUnseenPostEvent(Post p) {
    unseenPostEvent.value = p;
  }
}

class HBaseStateService {

  static void triggerBlockProfileEvent(Profile p) {
    HBaseStateManager hsm = Get.find();
    hsm.updateBlockProfileEvent(p);
  }

  static void triggerUnseenPostEvent(Post p) {
    HBaseStateManager hsm = Get.find();
    hsm.updateUnseenPostEvent(p);
  }

}