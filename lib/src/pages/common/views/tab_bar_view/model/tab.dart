import 'package:quiver/core.dart';

/// 注意为了避免与 Material 的 Tab 组件冲突，更名为 TabData
/// Tip：项目可能不叫 Tab 而是叫做 Channel 或者 Category，无论叫什么，直接 extends Tab 即可。
class TabData {
  final String id;
  final String name;
  /// 是否默认展示
  final bool? isDefault;

  TabData({required this.id, required this.name, this.isDefault});

  /// 重载 == 方法
  /// 
  /// 有关 hash and equals 的比较好的文章记录如下，
  /// - https://dart.dev/tools/linter-rules/hash_and_equals
  /// - https://stackoverflow.com/questions/20577606/whats-a-good-recipe-for-overriding-hashcode-in-dart
  @override
  bool operator ==(Object other) =>
      other is TabData &&
      other.runtimeType == runtimeType &&
      other.id == id &&
      other.name == name;


  /// 重载 hashCode
  /// 注意 [hash2] 方法需要使用到 https://pub.dev/packages/quiver
  @override
  int get hashCode => hash2(name.hashCode, id.hashCode);

}

class TabService {

  /// 从 [tabs] 中找到第一个 default 的 tab index，但要注意下面两种情况
  /// 1. 如果无意中设置了多个 default 则选择第一个，但是日志中会输出 warning msg
  /// 2. 如果没有任何一个设置 default，那么默认输出 0
  static getDefaultIndex(List<TabData> tabs) {
    // 如果没有找 isDefault 则通过 orElse 分支返回第一个 tab
    int index = tabs.indexWhere((tab) => tab.isDefault ?? false == true);
    // indexWhere 如果没有找到的话会返回 -1，这种情况下我们需要的是 0，转换！
    index = index == -1 ? 0 : index;
    return index;
  }
}