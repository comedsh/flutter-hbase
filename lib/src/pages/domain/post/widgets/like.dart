import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hbase/hbase.dart';
import 'package:ionicons/ionicons.dart';
import 'package:sycomponents/components.dart';

class StatefulLikeButton extends StatefulWidget {
  final Post post;
  final bool? isVertical;
  /// 设置图标的大小，默认值是 sp(30)
  final double? iconSize;
  /// 设置数字的文字大小，默认值是 sp(14)
  final double? fontSize;
  /// 设置不变的文本颜色（like num），默认为 null 即是可以兼容 dark/light theme；
  /// 这个参数是为了适配 [PostFullScreenView] 在 light theme 下需要固定使用白色的需求而设定的
  final Color? concretedFontColor;
  final Color? unactivedIconColor;
  final Color? activedIconColor;
  const StatefulLikeButton({
    super.key, 
    required this.post, 
    this.isVertical = true, 
    this.iconSize, 
    this.fontSize,
    this.concretedFontColor,
    this.unactivedIconColor,
    this.activedIconColor = Colors.redAccent
  });

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
          /// 只有当发生喜欢的时候才诱捕 Score Target
          if (isLiked.value == true) ScoreService.increaseScoreTarget();
        } catch (e, stacktrace) {
          debugPrint('Something really unknown throw from $StatefulLikeButton.onTap: $e, statcktrace below: $stacktrace');
          /// 这里提示错误并且还原状态
          /// 注：还原状态很简单，反向操作即可
          toggledVal ? widget.post.likes -- : widget.post.likes ++;
          isLiked.value = !toggledVal;
          showErrorToast(msg: '网络错误，操作失败', location: ToastLocation.CENTER);
        }
      },
      child: Obx(() => widget.isVertical!
      ? Column(
          children: [
            heartIcon(),
            SizedBox(height: sp(4)),
            likesNum(),
          ],
        )
      : Row(
          children: [
            heartIcon(),
            SizedBox(width: sp(4)),
            likesNum()
          ],
        )
      )  
    );
  }

  Icon heartIcon() => Icon(
    isLiked.value ? Ionicons.heart : Ionicons.heart_outline, 
    color: isLiked.value ? widget.activedIconColor : widget.unactivedIconColor,
    size: widget.iconSize ?? sp(30),
  );

  Text likesNum() => Text(
    /// 注意这里的 compactFormat 必须在 10000 的时候才会缩放
    compactFormat.format(widget.post.likes), 
    style: TextStyle(
      color: widget.concretedFontColor,
      fontSize: widget.fontSize ?? sp(14),      
    )
  );
}