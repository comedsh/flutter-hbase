import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hbase/hbase.dart';
import 'package:ionicons/ionicons.dart';
import 'package:sycomponents/components.dart';

class StatefulLikeIcon extends StatefulWidget {
  final Post post;
  const StatefulLikeIcon({super.key, required this.post});

  @override
  State<StatefulLikeIcon> createState() => _StatefulLikeIconState();
}

class _StatefulLikeIconState extends State<StatefulLikeIcon> {
  final isLiked = false.obs;

  @override
  void initState() {
    super.initState();
    isLiked.value = widget.post.isLiked;  
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        var isLiked_ = isLiked.value;  // keep the original 
        // toggle 提前设置
        isLiked.value = !isLiked.value;  
        var shortcode = widget.post.shortcode;
        try {
          isLiked_ 
            ? await HbaseUserService.disLike(shortcode)
            : await HbaseUserService.like(shortcode);
          widget.post.isLiked = true;  // 同步前端数据状态
        } catch (e, stacktrace) {
          debugPrint('Something really unknown throw from $StatefulLikeIcon.onTap: $e, statcktrace below: $stacktrace');
          /// 本地测试的时候可以添加一个休眠来测试前端状态的变化过程，否则太快无法看清
          // await Sleep.sleep(milliseconds: 3000);
          /// 这里提示错误并且还原状态
          isLiked.value = !isLiked.value;
          showErrorToast(msg: '网络错误，操作失败', location: ToastLocation.CENTER);
        }
      },
      child: Column(
        children: [
          Obx(() => Icon(
            isLiked.value ? Ionicons.heart : Ionicons.heart_outline, 
            size: sp(30),
          )),
          SizedBox(height: sp(4)),
          Text(compactFormat.format(widget.post.likes)),
        ],
      ),
    );
  }
}