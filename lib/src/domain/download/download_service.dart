// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:appbase/appbase.dart';
import 'package:flutter/material.dart';
import 'package:flutter_font_icons/flutter_font_icons.dart';
import 'package:get/get.dart';
import 'package:hbase/hbase.dart';
import 'package:sycomponents/components.dart';
import 'package:sypayment/sypayment.dart';

class DownloadService {

  /// 根据后台返回的 [DownloadStrategy] 来控制如何下载的行为，
  /// 1. 如果是会员，如果是无限次或者有下载配额则直接开启下载，配额下载会先询问一下
  /// 2. 如果有可用积分，则先询问是否使用积分，然后直接开启下载
  /// 3. 如果 #1 和 #2 都不满足，那么就显示可以供下载的售卖选项
  /// 
  /// 有关已下载再次下载的行为设计
  /// 1. Pay2Download
  ///    这里的 pay to download 中的 'pay' 不单单指付费，还包括支付积分，扣减每日会员配额以及评分下载（也是评分额度），
  ///    这些通通都是 'pay' 行为；与之对应的是 pay2DownloadCache 一个 TTL cache，为了确保用户在支付成功后的一段时间
  ///    内可以重复的发起下载；主要是考虑到这样一种场景，即用户支付成功后，结果没有开启相册权限导致下载失败，此时应该有这样
  ///    一种机制，可以确保用户可以再次发起下载；
  /// 2. UnlimitedDownload
  ///    购买的会员拥有无限次下载的权限，但是为了避免重复下载，仍然有一个提示，您已经下载该资源，是否继续下载？
  /// 3. 如何避免有效期内重复下载？
  ///    什么是有效重复下载？即是用户有权限可以重复下载此资源，且无需额外的支付行为，此时如果用户再次发起下载，这种清况我称之为有效期内
  ///    重复下载；那为什么要避免呢？其实是为了节省流量，因为用户已经下载过了，因此无需重复下载了；那么怎么实现呢？模仿微信的做法：给一
  ///    个提示，即使提示用户你已经下载过了，是否还要继续下载；那么为什么要分别设计两个 Cache，一个是 TTL Cache pay2DownloadCache 
  ///    和一个永久 Cache unlimitedDownloadCache 来两分别处理 [Pay2Download] 和 [UnlimitedDownload] 两种情况呢？因为两者的性
  ///    质不同，拥有无限次下载的会员很可能会退订，而且 unlimitedDownloadCache 是永久性的 cache，因此触发它的时机不同，必须先验证用
  ///    户权限后才去检查 Cache 的有效性；而基于 TTL 的 pay2DownloadCache 是临时的，不用太担心用户退订的问题，因此只要 pay2DownloadCache
  ///    在有效期内，那么即可发起下载；因此两种不同的 cache 处理的是两种不同的有效期行为；
  /// 
  static Future<void> downloadChoice(BuildContext context, Post post) async {

    /// 如果 payToDownload 还在缓存有效期内，则直接发起下载
    if (await DownloadCache.isPay2DownloadCacheValid(post)) {
      var isConfirmed = await showConfirmDialog(
        context, 
        content: '您已下载过此${post.typeName}，是否继续下载？',
        confirmBtnTxt: '是的',
        cancelBtnTxt: '不了',
      );
      if (isConfirmed) DownloadService.triggerDownload(context, post);
      return;
    } 

    /// 有关 GlobalLoading 的说明，关闭不能放到 finally 中执行，因为 modal Bottomsheet 会阻塞关闭直到其关闭为止
    GlobalLoading.show();
    try { 
      var ds = await DownloadService.getDownloadStrategy(post.type);
      GlobalLoading.close();

      /// 如果用户拥有无限次下载权限，那么为了避免有效期内重复下载，那么首先提示是否已经下载过了；注意，因为 unlimitedDownloadCache
      /// 是永久性缓存，因此在基于该缓存判断下载有效期的时候务必首先确保用户拥有无限次下载权限。
      if (ds.unlimitToDownload == true) {
        if (await DownloadCache.isUnlimitedCacheDownloadValid(post)) {
          var isConfirmed = await showConfirmDialog(
            context, 
            content: '您已下载过此${post.typeName}，是否继续下载？',
            confirmBtnTxt: '是的',
            cancelBtnTxt: '不了',
          );
          if (isConfirmed) triggerDownload(context, post);
        } else {
          triggerDownload(context, post);
          DownloadCache.cacheUnlimitedDownload(post);
        }
        return;
      }

      // 检查用户是否有每日的下载配额，如果有则发起下载
      if (ds.quotaToDownload != null) {
        var quota = ds.quotaToDownload?.quota;
        var isConfirmed = await showConfirmDialogWithoutContext(
          content: '今天剩余下载配额 $quota 次，是否使用？',
          confirmBtnTxt: '是的',
          cancelBtnTxt: '不了'
        );
        if (isConfirmed) {
          // TODO 再次验证是否有充足的配额
          DownloadService.triggerDownload(context, post); 
          DownloadCache.cachePay2Download(post); // 缓存下载有效期
          // TODO 扣减配额
        }
        return;
      }

      // 检查用户是否有足够的积分能够支持下载，注意 pointToDownload 能够返回则说明检查的时候积分是够用的
      if (ds.pointToDownload != null) {
        var remainPoints = ds.pointToDownload?.remainPoints;
        var pointToSpent = ds.pointToDownload?.pointToSpent;
        var isConfirmed = await showConfirmDialogWithoutContext(
          content: '下载需支付 $pointToSpent 积分，是否使用？',
          confirmBtnTxt: '是的',
          cancelBtnTxt: '不了'
        );
        if (isConfirmed) {
          // TODO 开启下载，下载之前还是要先到服务器上确认一下，下载完成后需要提示剩余积分数量
          // 上面返回的 remainPoints 应该不需要了，需要获取最新的
          DownloadService.triggerDownload(context, post); 
          DownloadCache.cachePay2Download(post); // 缓存下载有效期
          // TODO 扣减积分，然后返回剩余积分数量
        }
        return;
      }

      /// 如果支持付费下载，那么这里需要提前解析出必要参数 pd
      ProductDetails? pd;
      if (ds.payToDownload != null) {
        var iapProductId = ds.payToDownload!.iapProductId;
        pd = await PaymentParser.parseSingle(iapProductId);
      }

      /// 构建下载 items
      if (context.mounted) {
        await showModalBottomSheet(
          context: context, 
          builder: (BuildContext context) {
            return SafeArea(
              child: TitleContentBox(
                  gradient: Get.isDarkMode 
                  ? null 
                  : LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Colors.purple.shade50, Colors.white54]
                    ),
                  title: '下载',
                  body: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: ListTile.divideTiles(
                      context: context,
                      tiles:[
                        /// 注意在七颜第一次上线的时候，in-app-purchase consumable iap product 没有审核通过，导致展示失败
                        /// 如果审核没有通过这里的 pd 为 null 也就不展示即可，因此 pd != null 是为了兼容这种情况
                        ds.payToDownload != null && pd != null
                          ? DownloadService.listTileItem(
                              icon: Icon(MaterialIcons.save_alt, size: sp(26)),
                              title: '付费保存', 
                              // pd.price = pd.currencySymbol + pd.rawPrice，因此直接使用 pd.price 即可
                              subTitle: '支付 ${pd.price} 即可下载此${post.typeName}', 
                              btnText: '支付', 
                              btnClickedCallback: () async {
                                ManualPaymentHandler handler = ManualPaymentHandler();
                                handler.buy(pd!, 
                                  successCallback: () async {
                                    if (context.mounted) {
                                      DownloadService.triggerDownload(context, post);
                                      await DownloadCache.cachePay2Download(post); // 缓存下载有效期
                                    }
                                  },
                                  failCallback: () async {
                                    await showAlertDialogWithoutContext(content: '支付异常，请稍后再试');
                                  }
                                );
                              }
                            )
                          : Container(),
                        ds.purchaseSubscrDesc != null 
                          ? DownloadService.listTileItem(
                              icon: Icon(Icons.diamond_outlined, size: sp(26)),
                              title: '加入会员', 
                              subTitle: ds.purchaseSubscrDesc!, 
                              btnText: '查看', 
                              btnClickedCallback: () => Get.to(() => SalePage(
                                saleGroups: AppServiceManager.appConfig.saleGroups,
                                initialSaleGroupId: SaleGroupIdEnum.subscr,
                              ))
                            )
                          : Container(),
                        ds.purchasePointDesc != null 
                          ? DownloadService.listTileItem(
                              icon: const Icon(Ionicons.server_outline),
                              title: '购买积分', 
                              subTitle: ds.purchasePointDesc!, 
                              btnText: '查看', 
                              btnClickedCallback: () => Get.to(() => SalePage(
                                saleGroups: AppServiceManager.appConfig.saleGroups,
                                initialSaleGroupId: SaleGroupIdEnum.points,
                              ))
                            )           
                          : Container(),
                        ds.scoreToDownload != null 
                          ? DownloadService.listTileItem(
                              icon: Icon(Octicons.thumbsup, size: sp(24)),
                              title: ds.scoreToDownload!.title,
                              subTitle: ds.scoreToDownload!.content, 
                              btnText: ds.scoreToDownload!.btnText, 
                              btnClickedCallback: () {}
                            )
                          : Container()
                      ]
                    ).toList()
                  )
              ),
            );
          }
        );
      }

    } catch(e, stacktrace) {
      // No specified type, handles all
      debugPrint('Something really unknown throw from ${DownloadService.getDownloadStrategy}: $e, statcktrace below: $stacktrace');
      GlobalLoading.close();
      showErrorToast(msg: '网络异常，请稍后再试');
    } 

  }

  /// [loading] 是为测试环境准备的，我发现如果在 Unit test 环境中执行 GlobalLoading.show/clsoe 会报错，目前没有找到解决方案
  /// 为了不影响测试，就先暂时设置这样一个参数在测试环境中禁用 GlobalLoading
  static Future<DownloadStrategy> getDownloadStrategy(PostType postType) async {
      var r = await dio.post('/u/download/strategy', data: {
        "postType": postType.name
      });
      var data = r.data;
      debugPrint('downloadStrategy: ${const JsonEncoder.withIndent('  ').convert(data)}');
      var downloadStrategy = DownloadStrategy.fromJson(data['downloadStrategy']);
      return downloadStrategy;
  }

  /// 构建下载选项的通用元素 listTile
  static ListTile listTileItem({
    required Icon icon,
    required String title,
    required String subTitle,
    required String btnText,
    required VoidCallback? btnClickedCallback,
  }) {
    return ListTile(
      leading: SizedBox(
        width: sp(60),
        /// 添加 Wrap 的目的是让 icon 能够居中展示
        child: Wrap(
          alignment: WrapAlignment.center,
          children: [icon]
        ),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subTitle),
      trailing: SizedBox(
        width: sp(70),
        child: Wrap(
          alignment: WrapAlignment.start,                        
          children: [
            /// 备注：sp(15.0) 是为了避免在 SE 屏幕下字体展示宽度不够的问题
            TextButton(
              onPressed: btnClickedCallback, 
              child: Text(btnText, style: TextStyle(fontWeight: FontWeight.bold, fontSize: sp(15)))
            ),
          ],
        )
      ),
      contentPadding: const EdgeInsets.all(4.0),
    );
  }

  /// 发起下载
  /// 考虑一种场景，就是 cdn signed url 在用户下载的时候可能已经过期了，最好是从服务器上去加载最新的有效的 cdn signed url
  static triggerDownload(BuildContext context, Post post) async {
    try {
      List<String> urls = [];
      // 注意，如果是视频资源则不要追加封面到下载列表中了
      for (var slot in post.slots) {
        if (slot.video != null) {
          urls.add(slot.video!);
        } else {
          urls.add(slot.pic);
        }
      }
      await showImgDownloader(context, urls: urls, appName: AppServiceManager.appConfig.appName);
    } catch (e, stacktrace) {
      debugPrint('Something really unknown: $e, statcktrace below: $stacktrace');
    }
  }

}
