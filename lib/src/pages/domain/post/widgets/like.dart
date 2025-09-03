import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hbase/hbase.dart';
import 'package:ionicons/ionicons.dart';
import 'package:sycomponents/components.dart';

class StatefulLikeButton extends StatefulWidget {
  final Post post;
  const StatefulLikeButton({super.key, required this.post});

  @override
  State<StatefulLikeButton> createState() => _StatefulLikeButtonState();
}

class _StatefulLikeButtonState extends State<StatefulLikeButton> {
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
        // toggle 提前设置
        var toggledVal = !isLiked.value;
        /// 首先必须递增收藏数量，因为一旦修改 isFavorited obs 就会立刻更新页面，因此必须赶在之前递增
        /// toggaleVal 如果等于 true 则表示收藏，因此 ++，相反则表示取消收藏，因此 -- 
        toggledVal ? widget.post.likes ++ : widget.post.likes --;
        isLiked.value = toggledVal;  
        var shortcode = widget.post.shortcode;
        try {
          /// toggledVal 是原本 favorited 反值，因此再反一次就获得的是提前转换（“提前亮”）之前的原始值，因此 !toggleVal 就
          /// 表示原始值即 isFavoriate.value 为 true，因此用户点击按钮的目的是取消收藏，因此这里调用 disFavorites
          !toggledVal 
            ? await HBaseUserService.disLike(shortcode)
            : await HBaseUserService.like(shortcode);
          widget.post.isLiked = isLiked.value;  // 同步前端数据状态
        } catch (e, stacktrace) {
          debugPrint('Something really unknown throw from $StatefulLikeButton.onTap: $e, statcktrace below: $stacktrace');
          /// 这里提示错误并且还原状态
          /// 注：还原状态很简单，反向操作即可
          toggledVal ? widget.post.likes -- : widget.post.likes ++;
          isLiked.value = !toggledVal;
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
          Text(compactFormat.format(widget.post.likes), style: TextStyle(fontSize: sp(14))),
        ],
      ),
    );
  }
}