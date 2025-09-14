import 'package:format/format.dart';
import 'package:hbase/hbase.dart';
import 'package:sycomponents/components.dart';

class DownloadCache {
  static String downloadCacheKey = 'dwn_{shortcode}';
  /// 支付后再次下载免费的有效期
  static int expireSeconds = 3600 * 12; // 12 个小时

  static cacheDownload(Post post) async {
    await PersistentTtlLockService().create(
      name: DownloadCache.downloadCacheKey.format({#shortcode: post.shortcode}),
      expireSecs: DownloadCache.expireSeconds
    );
  }

  static Future<bool> isDownloadCacheValid(Post post) async {
    var key = DownloadCache.downloadCacheKey.format({#shortcode: post.shortcode});
    return await PersistentTtlLockService().isLocked(key);
  }

}