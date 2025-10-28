
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import 'package:sycomponents/components.dart';
import 'package:visibility_detector/visibility_detector.dart';

class ClearCacheListTile extends StatefulWidget {
  final double? fontSize;
  /// 缓存分别来源于 [SharedPreferences], dio 使用到的 [hive], 缓存图片使用到的 [cached_network_image],
  /// 以及缓存视频使用到的 cached video 框架；前面上个都好删除，唯独第四个无法删除；因此就象征性的把 
  /// [SharedPreferences] 和 [hive] 中的数据删除得了；并且做一个假的 loding...
  const ClearCacheListTile({super.key, this.fontSize});

  @override
  State<ClearCacheListTile> createState() => _ClearCacheListTileState();
}

class _ClearCacheListTileState extends State<ClearCacheListTile> {

  var size = '0K'.obs;

  late CachePurgeService cachePurgeService;

  @override
  void initState() {
    super.initState();
    // 图片不删除，否则加载太慢了
    cachePurgeService = CachePurgeService(isPurgeImageCache: false, isPurgeVideoCache: true);
    WidgetsBinding.instance.addPostFrameCallback((_) => doUpdate());
  }

  activated() async {
    await doUpdate();
  }

  deactivated() {
  }

  /// update the size
  doUpdate() async {
    debugPrint('============> size: $size');
    size.value = await cachePurgeService.getCacheSize();
  }

  @override
  Widget build(BuildContext context) {
    // 使用 Visible Detector 的目的是每次进入用户中心的时候都会自动更新所占用的缓存
    return VisibilityDetector(
      key: Key('ClearCacheMenuItem-${UniqueCode.uniqueShortCode}'),
      onVisibilityChanged: (VisibilityInfo info) => info.visibleFraction > 0 ? activated(): deactivate(),
      child: ListTile(
        leading: const Icon(Ionicons.trash_outline),
        title: Obx(() => Text('清除缓存（${size.value}）', style: TextStyle(fontSize: widget.fontSize ?? sp(18)))),
        trailing: const Icon(Ionicons.chevron_forward_outline),
        onTap: () async {
          bool choice = await showConfirmDialog(context, content: '确定清除缓存？', confirmBtnTxt: '是', cancelBtnTxt: '否');
          if (choice) {
            GlobalLoading.show();
            await cachePurgeService.purge();
            GlobalLoading.close();
            if (context.mounted) {
              await showAlertDialog(context, content: '已为您清除缓存 $size', confirmBtnTxt: '好的');
              await doUpdate();
            }
          }
        },
      ),
    );
  }
}