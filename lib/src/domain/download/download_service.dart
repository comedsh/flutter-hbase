// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:convert';

import 'package:appbase/appbase.dart';
import 'package:flutter/material.dart';
import 'package:flutter_font_icons/flutter_font_icons.dart';
import 'package:get/get.dart';
import 'package:hbase/hbase.dart';
import 'package:sycomponents/components.dart';
import 'package:sypayment/sypayment.dart';
import 'package:http/http.dart' as http;

class DownloadService {

  /// 根据后台返回的 [DownloadStrategy] 来控制如何下载的行为，
  /// 1. 如果是会员，如果是无限次或者有下载配额则直接开启下载，配额下载会先询问一下
  /// 2. 如果有可用积分，则先询问是否使用积分，然后直接开启下载
  /// 3. 如果 #1 和 #2 都不满足，那么就显示可以供下载的售卖选项
  /// 
  /// 已下载有效期内的重复下载设计
  /// HuoCool 之前设计得太复杂了，后台设计了一套完备的下载记录用于判断用户是否可以在有效期内重复下载；不想搞得那么的复杂，现在
  /// 这套重复下载的设计放到前端轻量级的进行处理了，前端给一个短时间的 ttl cache，主要的目的是为了避免用户单次付费下载后因为相
  /// 册权限或者网络临时性的问题下载失败后，可以再次无需付费直接发起下载；因此在该 cache 失效之前，都是可以直接发起重复下载的；
  /// 有一些副作用，就是如果用户的会员退订，积分交易取消等，退订和取消之前的缓存下载在有效期内依然可以被下载，但是没有关系，因为
  /// ttl 的时间不会太长，现在默认设置的是 12 个小时，因此影响不大。
  /// 
  /// 有关 GlobalLoading 的说明，关闭不能 [downloadChoice] 的 finally 方法中关闭，因为 BottomSheet 会阻塞其关闭直到
  /// BottomSheet 关闭为止；
  /// 
  /// 是否需要对资源 URL 进行 reSign？
  /// 
  /// 如何测试？
  /// 里面的分支众多，想要快速进行测试，最快的方法便是结合后台的 beaut/trade-test.test.ts 模块快速创建模拟交易进行
  /// 
  static Future<void> downloadChoice(BuildContext context, Post post) async {

    /// 如果 payToDownload 还在缓存有效期内，则直接发起下载
    if (await DownloadCache.isDownloadCacheValid(post)) {
      var isConfirmed = await showConfirmDialog(
        context, 
        content: '您已下载过此${post.typeName}，是否继续下载？',
        confirmBtnTxt: '继续',
        cancelBtnTxt: '不了',
      );
      if (isConfirmed) await DownloadService.triggerDownload(context, post);
      return;
    } 

    var ds = await DownloadService.getDownloadStrategy(post.type);

    /// 如果用户拥有无限次下载权限
    if (ds.unlimitToDownload == true) {
      await triggerDownload(context, post);
      await DownloadCache.cacheDownload(post);
      return;
    }

    // 检查用户是否有每日的下载配额，如果有则发起下载
    if (ds.quotaToDownload != null) {
      var quotaRemains = ds.quotaToDownload?.quotaRemains;
      await DownloadHandler.spendQuota2Download(context, quotaRemains!, post);
      return;
    }

    // 检查用户是否有足够的积分能够支持下载，注意 pointToDownload 能够返回则说明检查的时候下载次资源的积分是够的
    if (ds.pointToDownload != null) {
      var pointToSpend = ds.pointToDownload?.pointToSpend;
      await DownloadHandler.spendPoint2Download(context, pointToSpend!, post);
      return;
    }

    /// 当上述条件都不满足的时候展示 Bottom sheet
    await showBottomSheet(context, ds, post);

  }

  static showBottomSheet(BuildContext context, DownloadStrategy ds, Post post) async {

    /// 如果支持付费下载，那么这里需要提前解析出必要参数 pd
    ProductDetails? pd;
    if (ds.payToDownload != null) {
      var iapProductId = ds.payToDownload!.iapProductId;
      pd = await PaymentParser.parseSingle(iapProductId);
    }

    /// 构建下载 items
    if (context.mounted) {
      await showModalBottomSheet(
        // 重要属性，默认 bottom sheet 高度只能是 534，使用 scroll 避免溢出
        isScrollControlled: true,
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
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: ListTile.divideTiles(
                    context: context,
                    tiles:[
                      /// 注意在七颜第一次上线的时候，in-app-purchase consumable iap product 没有 chk 通过，导致展示失败
                      /// 如果 chk 没有通过这里的 pd 为 null 也就不展示即可，因此 pd != null 是为了兼容这种情况
                      ds.payToDownload != null && pd != null
                        ? DownloadWidget.listTileItem(
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
                                    await DownloadService.triggerDownload(context, post);
                                    await DownloadCache.cacheDownload(post); // 缓存下载有效期
                                    Get.back();  // 关闭 BottomSheet;
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
                        ? DownloadWidget.listTileItem(
                            icon: Icon(Icons.diamond_outlined, size: sp(26)),
                            title: '加入会员', 
                            subTitle: ds.purchaseSubscrDesc!, 
                            btnText: '查看', 
                            btnClickedCallback: () {
                              /// 为什么使用 AppState manualTradeSuccess 来捕获交易成功事件的详细原因参考“购买积分”代码部分；
                              // var sm = Get.find<AppStateManager>();
                              /// 注意这个监听器必须放到跳转到交易界面之前执行，否则下面的 await 会导致它的监听还没有启动
                              // once(sm.manualTradeSuccess, (_) {
                              //   debugPrint('AppState manualTradeSuccess event caught, now try to close BottomSheet');
                              //   Get.back();
                              // });
                              /// 因为最终还是采用了 closeOverlays 的方法，即使在 Get.back 的同时就已经将 app 中的所有诸如 BottomSheets 这样的 
                              /// Overlays 关闭了，因此这里也就无需监听结果来关闭了
                              // ignore: unused_local_variable
                              // Get.to(() => SalePage(
                              //   saleGroups: AppServiceManager.appConfig.saleGroups,
                              //   initialSaleGroupId: SaleGroupIdEnum.subscr,
                              // ));
                              var sm = Get.find<AppStateManager>();
                              once(sm.manualSubscrTradeSuccess, (_) {
                                debugPrint('AppState manualSubscrTradeSuccess event caught, now try to close BottomSheet');
                                Get.back();
                              });
                              /// 至于为什么最终放弃使用 Get.to 参考购买积分处的注解
                              Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (BuildContext context) => SalePage(
                                    saleGroups: AppServiceManager.appConfig.saleGroups,
                                    initialSaleGroupId: SaleGroupIdEnum.subscr,
                                    backgroundImage: (AppServiceManager.appConfig as HBaseAppConfig).salePageBackgroundImage,
                                  ),
                                ),
                              );                                   
                            }
                          )
                        : Container(),
                      ds.purchasePointDesc != null 
                        ? DownloadWidget.listTileItem(
                            icon: const Icon(Ionicons.server_outline),
                            title: '购买积分', 
                            subTitle: ds.purchasePointDesc!, 
                            btnText: '查看', 
                            btnClickedCallback: () async { 
                              /// 🚩______时间线1______
                              /// 下面记录为什么这里无法接收到 Get.back result 的原因
                              /// 经过多轮测试，发现是因为 BottomSheet 的原因导致无法接受到 Get.back 的返回值 result，这是 Overlays 导致
                              /// 的，dialog, snackbar, or bottom sheet 都称之为 Overlays；下面是 Google AI 的回答：
                              /// If Get.back() is not closing a dialog, snackbar, or bottom sheet and returning to the previous
                              /// screen as expected, it might be because these overlays are still active. You can address this 
                              /// by:
                              ///  - Using Get.back(closeOverlays: true): This explicitly tells GetX to close any open overlays 
                              ///    when navigating back.
                              ///  - Manually closing overlays: If you have multiple overlays, you might need to close them 
                              ///    individually using Get.snackbar().close(), Get.dialog().close(), or Get.bottomSheet().close() 
                              ///    before calling Get.back().
                              /// 🚩______时间线2______
                              /// 试过上面的 Get.back(closeOverlays: true) 方式后，的确这里可以接收到返回值了，也基本上能够满足我的需要了，但是
                              /// 毕竟 SalePage 是一个通用的页面，如果不管三七二十一在返回的时候通通的将 Overlays 关闭掉，将来一定会埋下隐藏的 BUG，
                              /// 因此取而代之，创建了一个新的 AppState manualTradeSuccess 来处理这种情况，当交易成功后触发该事件，这里捕获然后关
                              /// 闭 BottomSheet；如下代码所示
                              // var sm = Get.find<AppStateManager>();
                              /// 注意这个监听器必须放到跳转到交易界面之前执行，否则下面的 await 会导致它的监听还没有启动
                              /// 🚩______时间线3______
                              /// 注意，实测中发现，之前和 subscr 交易共用一个 manualTradeSuccess 事件，结果两个地方同时会发生监听... 为什么呢？
                              /// 明明积分交易的 btnClickedCallback 被点击了呀 ... 为什么会员交易的 btnClickedCallback 中的 once listen 也被初始化了？唯
                              /// 一的解释就是编译优化 ...
                              /// ----
                              /// 于是最终决定还是采用最简单直接的 closeOverlays 参数的方式，不再使用 manualTradeSuccess 状态
                              // once(sm.manualTradeSuccess, (_) {
                              //   debugPrint('AppState manualTradeSuccess event caught, now try to close BottomSheet');
                              //   Get.back();
                              // });
                              /// 备注：即便是采用了 AppState manualTradeSuccess 后，这里依然要阻塞，否则 btnClickedCallback 局部方法会被释放掉
                              /// ---
                              /// 因为最终还是采用了 closeOverlays 的方法，即使在 Get.back 的同时就已经将 app 中的所有诸如 BottomSheets 这样的 
                              /// Overlays 关闭了，因此这里也就无需监听结果来关闭了
                              // ignore: unused_local_variable
                              // var result = await Get.to(() => SalePage(
                              //   saleGroups: AppServiceManager.appConfig.saleGroups,
                              //   initialSaleGroupId: SaleGroupIdEnum.points,
                              // ));
                              /// 正如上述注解中所描述的那样，现在暂时放弃这种做法
                              // debugPrint('result: $result');
                              // 如果确认交易成功后，关闭 bottomSheet
                              // if (result == true) Get.back();
                              /// 🚩______时间线5______
                              /// 既然 closeOverlays 会导致会员中心页面崩溃，如果从会员中心跳转到 SalePage 购买成功后跳转回来，导致页面崩溃，因此
                              /// 最终还是通过 GetX events 来实现，为了避免同时被两个方法句柄监听的问题，这次分别定义饿了两个状态 manualPointTradeSuccess
                              /// 和 manualSubscrTradeSuccess 状态事件。
                              var sm = Get.find<AppStateManager>();
                              once(sm.manualPointTradeSuccess, (_) {
                                debugPrint('AppState manualPointTradeSuccess event caught, now try to close BottomSheet');
                                // 还是给一个有好的提示吧
                                Timer(const Duration(milliseconds: 500), () =>
                                  showInfoToast(msg: '购买积分成功，点击下载按钮即可开启下载', showInSecs: 5)
                                );
                                Get.back();
                              });
                              /// 🚩______时间线4______
                              /// 哈哈，最后我连 Get.to 路由都放弃了，因为我发现它在真机上有一个莫名其妙的 bug，就是随便选择购买会员或者积分进入 SalePage 
                              /// 后，此时我发起了某项支付，但是中途点击 x 按钮取消，然后点击 SalePage 上的左上角关闭按钮返回当前页面，并且继续点击 BottomSheet 
                              /// 中的购买积分或者会员的“查看“按钮，结果无法跳转了... 真的是遇到鬼了，改成原生的 Navigator 就没有问题了；看来 GetX 上面的
                              ///  BUG 还是很多呀！使用的时候可得注意了
                              await Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (BuildContext context) => SalePage(
                                    saleGroups: AppServiceManager.appConfig.saleGroups,
                                    initialSaleGroupId: SaleGroupIdEnum.points,
                                    backgroundImage: (AppServiceManager.appConfig as HBaseAppConfig).salePageBackgroundImage,
                                  ),
                                ),
                              );                              
                            }
                          )           
                        : Container(),
                      ds.scoreToDownload != null 
                        ? DownloadWidget.listTileItem(
                            icon: Icon(Octicons.thumbsup, size: sp(24)),
                            title: ds.scoreToDownload!.title,
                            subTitle: ds.scoreToDownload!.content, 
                            btnText: ds.scoreToDownload!.btnText, 
                            btnClickedCallback: () => ScoreService.jumpToScore()
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

  }

  /// [loading] 是为测试环境准备的，我发现如果在 Unit test 环境中执行 GlobalLoading.show/clsoe 会报错，目前没有找到解决方案
  /// 为了不影响测试，就先暂时设置这样一个参数在测试环境中禁用 GlobalLoading
  static Future<DownloadStrategy> getDownloadStrategy(PostType postType) async {
      try {
        GlobalLoading.show();
        var r = await dio.post('/u/download/strategy', data: {
          "postType": postType.name
        });
        var data = r.data;
        debugPrint('downloadStrategy: ${const JsonEncoder.withIndent('  ').convert(data)}');
        var downloadStrategy = DownloadStrategy.fromJson(data['downloadStrategy']);
        return downloadStrategy;
      } catch (e, stacktrace) {
        // No specified type, handles all
        debugPrint('Something really unknown throw from ${DownloadService.getDownloadStrategy}: $e, statcktrace below: $stacktrace');
        showErrorToast(msg: '网络异常，请稍后再试');
        rethrow;
      } finally {
        GlobalLoading.close();
      }
  }

  /// 发起下载
  /// 考虑一种场景，就是 cdn signed url 在用户下载的时候可能已经过期了，最好是从服务器上去加载最新的有效的 cdn signed url
  static Future<bool> triggerDownload(BuildContext context, Post post) async {
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
      GlobalLoading.show();
      /// check the urls availability：如果有任何一个返回不可以下载，则发起重新签名；
      if (await __isUrlsAccessible(urls) == false) {
        debugPrint('post ${post.shortcode} url signed time invalid, start to resign the urls');
        urls = await __reSignCdn(urls);
      }
      var val = await showImgDownloader(context, urls: urls, appName: AppServiceManager.appConfig.appName);
      return val == 'done';  // 如果返回 'done' 则表示下载成功
    } catch (e, stacktrace) {
      debugPrint('Something really unknown: $e, statcktrace below: $stacktrace');
    } finally {
      GlobalLoading.close();
    }
    return false;
  }
  
  /// 因为只是验证 CDN 签名，因此只要有任何一个链接不可反问则返回 false，相应的，如果任何一个返回 true 也返回 true 即表示签名可用
  /// 注意：之前挂了腾讯的 VPN 导致检查得异常的慢，只要把 VPN 关闭访问就好了；
  static Future<bool> __isUrlsAccessible(List<String> urls) async {
    for (var url in urls) {
      final response = await http.head(Uri.parse(url));
      debugPrint('response statusCode ${response.statusCode} accessible test for $url');
      if (response.statusCode != 200) {
        return false;
      } else {
        return true;
      }
    }
    return false;
  }

  /// 将无效的链接发送到后台进行重新签名，然后返回新签名后的链接
  static Future<List<String>> __reSignCdn(List<String> urls) async {
    try {
      var r = await dio.post('/post/resign/urls', data: {
        "urls": urls
      });
      // covnert r.data List<dynamic> to List<String>
      return r.data.map<String>((url) => url.toString()).toList();
    } catch(e, stacktrace) {
      debugPrint('__reSignCdn get error: $e, stacktrace: $stacktrace');
      showErrorToast(msg: '网络异常，请稍后再试');
      rethrow;
    }
  }

}

class DownloadHandler {

  /// [pointToSpend] 由后台返回，表示下载该资源需要消费多少的积分；但是要知道的是，用户可能多个终端
  /// 同一个账号再不断的发起下载，因此实际上下载的时候，后台还是需要判断，如果不能下载则提示报错信息
  /// 测试说明：使用后台 beaut/trade-test.test.ts 快速模拟创建和删除积分交易
  static spendPoint2Download(BuildContext context, int pointToSpend, Post post) async {
    var isConfirmed = await showConfirmDialogWithoutContext(
      content: '下载需支付 $pointToSpend 积分，是否使用？',
      confirmBtnTxt: '使用',
      cancelBtnTxt: '不了'
    );
    if (isConfirmed) {
      try {
        GlobalLoading.show();
        // 该 post 请求会再次检查当前用户的积分是否够用并同时扣除积分，如果积分不足，则会返回通知类型异常 580，由框架处理
        var r = await dio.post('/u/download/point', data: {
          'shortcode': post.shortcode,
          'postType': post.type.name
        });
        GlobalLoading.close();  // 需要放到 Download widget 之前关闭，否则可能无法关闭
        var isSuccess = await DownloadService.triggerDownload(context, post);
        await DownloadCache.cacheDownload(post); // 缓存下载有效期
        /// 即便是下载过程失败，可能因为权限问题失败，也或者是网络临时出现问题，下载没有成功；但是记住，下载状态已经保存到本地了
        /// 也就是说，用户随时可以重启下载，因此积分照扣，只是不提示余额了。
        if (isSuccess) {
          Timer(const Duration(milliseconds: 600), () => showInfoToast(msg: r.data['msg'], location: ToastLocation.CENTER));
        }
      } catch (err) {
        GlobalLoading.close();
        debugPrint('$err');
      }
    }
  }

  /// 同 [spendPoint2Download] 一样，在发起下载前依然要再次检查配额
  /// 测试说明：使用后台 beaut/trade-test.test.ts 快速模拟创建和删除会员交易
  static spendQuota2Download(BuildContext context, int quotaRemains, Post post) async {
    var isConfirmed = await showConfirmDialogWithoutContext(
      content: '今天剩余下载配额 $quotaRemains 次，是否使用？',
      confirmBtnTxt: '使用',
      cancelBtnTxt: '不了'
    );
    if (isConfirmed) {
      try {
        GlobalLoading.show();
        // 该 post 请求会再次检查当前用户的配额是否够用并同时保存下载记录，如果配额不足，则会返回通知类型异常 580，由框架处理
        var r = await dio.post('/u/download/quota', data: {
          'shortcode': post.shortcode,
        });
        GlobalLoading.close();  // 需要放到 Download widget 之前关闭，否则可能无法关闭
        var isSuccess = await DownloadService.triggerDownload(context, post); 
        await DownloadCache.cacheDownload(post); // 缓存下载有效期
        /// 即便是下载过程失败，可能因为权限问题失败，也或者是网络临时出现问题，下载没有成功；但是记住，下载状态已经保存到本地了
        /// 也就是说，用户随时可以重启下载，因此配额照扣，只是不提示余额了。
        if (isSuccess) {
          Timer(const Duration(milliseconds: 600), () => showInfoToast(msg: r.data['msg'], location: ToastLocation.CENTER));
        }
      } catch (err) {
        GlobalLoading.close();
        debugPrint('$err');
      }
    }
  }

}

class DownloadWidget {
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

}
 