import 'dart:convert';

import 'package:appbase/appbase.dart';
import 'package:flutter/material.dart';
import 'package:flutter_font_icons/flutter_font_icons.dart';
import 'package:get/get.dart';
import 'package:hbase/hbase.dart';
import 'package:sycomponents/components.dart';

class DownloadService {

  /// 
  static Future<void> showDownloadItems(BuildContext context, PostType postType) async {
    /// 有关 GlobalLoading 的说明，关闭不能放到 finally 中执行，因为 modal Bottomsheet 会阻塞关闭直到其关闭为止
    GlobalLoading.show();
    try { 
      var ds = await DownloadService.getDownloadStrategy(postType);
      GlobalLoading.close();
      /// Direct download ...
      
      if (ds.unlimitToDownload == true) {
        // TODO 直接发起下载了，但是如果已经下载需要提示已下载，这样尽可能的节省流量
        return;
      }

      // 注意如果能够返回的话表示用户当前有剩余的配额
      if (ds.quotaToDownload != null) {
        var quota = ds.quotaToDownload?.quota;
        var isConfirmed = await showConfirmDialogWithoutContext(
          content: '今天剩余下载配额 $quota 次，是否使用？',
          confirmBtnTxt: '是的',
          cancelBtnTxt: '不了'
        );
        if (isConfirmed) {
          // TODO 直接开始下载，注意还是要到服务器 checking 一下
        }
        return;
      }

      // 注意如果能够返回的话表示用户当前有足够的积分可供下载
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
        }
        return;
      }

      /// 构建下载 items
      if (context.mounted) {
        await showModalBottomSheet(
          context: context, 
          builder: (BuildContext context) {
            return TitleContentBox(
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
                      ds.purchaseSubscrDesc != null 
                        ? DownloadService.listTileItem(
                            icon: Icon(Icons.diamond_outlined, size: sp(26)),
                            title: '加入会员', 
                            subTitle: ds.purchaseSubscrDesc!, 
                            btnText: '查看', 
                            btnClickedCallback: () {

                            }
                          )
                        : Container(),
                      ds.purchasePointDesc != null 
                        ? DownloadService.listTileItem(
                            icon: Icon(Ionicons.server_outline, size: sp(26)),
                            title: '购买积分', 
                            subTitle: ds.purchasePointDesc!, 
                            btnText: '查看', 
                            btnClickedCallback: () {
                            }
                          )           
                        : Container(),
                      ds.scoreToDownload != null 
                        ? DownloadService.listTileItem(
                            icon: const Icon(Octicons.thumbsup), 
                            title: '五星好评', 
                            subTitle: ds.scoreToDownload!, 
                            btnText: '打分', 
                            btnClickedCallback: () {}
                          )
                        : Container()
                    ]
                  ).toList()
                )
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

