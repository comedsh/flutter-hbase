import 'package:format/format.dart';
import 'package:hbase/hbase.dart';
import 'package:sycomponents/components.dart';

class DownloadCache {
  static String downloadCacheKey = 'dwn_{shortcode}';
  static String pay2DownloadCacheKey = 'pay2dwn_{shortcode}';
  /// 支付后再次下载免费的有效期
  static int pay2DownloadValidTime = 3600 * 12; // 12 个小时

  /// 缓存任何与“支付行为”相关的下载记录，这类的支付不单单是指付款，他还包括积分支付，以及会员每日
  /// 下载配额的扣减，这些都是支付行为，如果是这些支付行为的下载，那么缓存其有效期，并且意味着在该
  /// 有效期内，用户可以重复下载，而无需再次付费、支付积分或者扣减会员每日额度
  /// 补充：还包括评分下载哦
  static cachePay2Download(Post post) async {
    await PersistentTtlLockService().create(
      name: DownloadCache.pay2DownloadCacheKey.format(#shortcode, post.shortcode),
      expireSecs: DownloadCache.pay2DownloadValidTime
    );
  }

  /// see [cachePay2Download]；另外这也是一个标志，表示用于已经下载过了，再次下载的话，可以基于
  /// 此条件询问用户是否继续下载
  static Future<bool> isPay2DownloadCacheValid(Post post) async {
    var key = DownloadCache.pay2DownloadCacheKey.format(#shortcode, post.shortcode);
    return await PersistentTtlLockService().isLocked(key);
  }

  /// 缓存除了 [cachePay2Download] 以外的下载记录
  /// 缓存任何下载记录，用于用户有资格下载后，检查曾经是否下载过使用的，如果下载过则提示是否继续下载
  /// 
  static cacheUnlimitedDownload(Post post) async {
    var lock = Lock(
      name: DownloadCache.downloadCacheKey.format(#shortcode, post.shortcode), 
      createTs: DateTime.now()
    );
    await PersistentLockService().save(lock);
  }

  /// 判断用户是否已经下载过
  static Future<bool> isUnlimitedCacheDownloadValid(Post post) async {
    var key = DownloadCache.downloadCacheKey.format(#shortcode, post.shortcode);
    return await PersistentLockService().isLocked(key);
  }

}