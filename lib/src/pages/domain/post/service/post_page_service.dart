import 'package:hbase/hbase.dart';

class PostPageService {

  /// 找到 post 在 posts 中的下标，如果没有找到则返回 null
  static int? getIndex(List<Post> posts, Post post) {
    int index = posts.indexWhere((p) => p.shortcode == post.shortcode);
    /// 如果没有找到则返回 -1 此时需要将其转换为 null
    return index == -1 ? null : index;
  }
}