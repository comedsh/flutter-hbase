import 'package:quiver/core.dart';

/// 注意为了避免与 Material 的 Tab 组件冲突，更名为 TabData
/// Tip：项目可能不叫 Tab 而是叫做 Channel 或者 Category，无论叫什么，直接 extends Tab 即可。
class TabData {
  final String id;
  final String name;

  TabData({required this.id, required this.name});

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