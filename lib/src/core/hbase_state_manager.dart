import 'package:get/get.dart';
import 'package:hbase/hbase.dart';

/// 这里定义 HBase 相关的全局的事件
/// 要激活 [HBaseStateManager] 记得一定要在子项目中的 [initSubGetxServices] 方法将其注入
class HBaseStateManager extends GetxService {
  Rx<Profile?> blockProfileEvent = Rx<Profile?>(null);
  Rx<Post?> unseenPostEvent = Rx<Post?>(null);  // unseen 译文为屏蔽，与字面意思吻合，因此取名 unseen
  Rx<bool> isBottomNavigationBarVisible = false.obs;

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

  /// 通过 [VisibilityDetector] 检测状态后赋值
  static void setBottomNavigationBarVisible(bool isVisible) => Get.find<HBaseStateManager>().isBottomNavigationBarVisible.value = isVisible;

  /// 这个方法唯一的弊端是，因为可见性是通过 [VisibilityDetector] 进行赋值的，而经过长期的实践发现，通过 [VisibilityDetector]
  /// 虽然可靠，但是有延迟... 因此布局上还需要通过 Obx 来进行状态管控，比如可能页面一开始获得的 visible 是 false，要等大概 300
  /// 毫秒以后才会得到准确的值 true。
  static bool isBottomNavigationBarVisible() => Get.find<HBaseStateManager>().isBottomNavigationBarVisible.value;

}