import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hbase/hbase.dart';
import 'package:ionicons/ionicons.dart';
import 'package:sycomponents/components.dart';

class StatefulFavoriteButton extends StatefulWidget {
  final Post post;
  /// 设置不变的文本颜色（like num），默认为 null 即是可以兼容 dark/light theme；
  /// 这个参数是为了适配 [PostFullScreenView] 在 light theme 下需要固定使用白色的需求而设定的
  final Color? concretedFontColor;
  final Color? unactivedIconColor;
  final Color? activedIconColor;
  const StatefulFavoriteButton({
    super.key, 
    required this.post, 
    this.concretedFontColor, 
    this.unactivedIconColor, 
    this.activedIconColor = Colors.amber,
  });

  @override
  State<StatefulFavoriteButton> createState() => _StatefulFavoriteButtonState();
}

class _StatefulFavoriteButtonState extends State<StatefulFavoriteButton> {
  final isFavorited = false.obs;

  @override
  void initState() {
    super.initState();
    isFavorited.value = widget.post.isFavorited;  
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        /// 提前设置 toggle 过程，
        var toggledVal = !isFavorited.value;
        /// 首先必须递增收藏数量，因为一旦修改 isFavorited obs 就会立刻更新页面，因此必须赶在之前递增
        /// toggaleVal 如果等于 true 则表示收藏，因此 ++，相反则表示取消收藏，因此 -- 
        toggledVal ? widget.post.favorites ++ : widget.post.favorites --;  // 同步前端数据状态
        isFavorited.value = toggledVal;  
        var shortcode = widget.post.shortcode;
        try {
          /// toggledVal 是原本 favorited 反值，因此再反一次就获得的是提前转换（“提前亮”）之前的原始值，因此 !toggleVal 就
          /// 表示原始值即 isFavoriate.value 为 true，因此用户点击按钮的目的是取消收藏，因此这里调用 disFavorites
          !toggledVal 
            ? await HBaseUserService.disFavorite(shortcode)
            : await HBaseUserService.favorite(shortcode);
          widget.post.isFavorited = isFavorited.value;
          /// 只有当发生收藏行为的时候才触发
          if (isFavorited.value == true) ScoreService.increaseScoreTarget();
        } catch (e, stacktrace) {
          debugPrint('Something really unknown throw from $StatefulFavoriteButton.onTap: $e, statcktrace below: $stacktrace');
          /// 这里提示错误并且还原状态
          /// 注：还原状态很简单，反向操作即可
          toggledVal ? widget.post.favorites -- : widget.post.favorites ++;
          isFavorited.value = !toggledVal;
          showErrorToast(msg: '网络错误，操作失败', location: ToastLocation.CENTER);
        }
      },
      child: Obx(() => Column(
        children: [
          Icon(
            isFavorited.value ? Ionicons.star : Ionicons.star_outline, 
            color: isFavorited.value ? widget.activedIconColor : widget.unactivedIconColor,            
            size: sp(30),
          ),
          SizedBox(height: sp(4)),
          Text(
            compactFormat.format(widget.post.favorites), 
            style: TextStyle(
              color: widget.concretedFontColor,
              fontSize: sp(14)
            )
          ),
        ],
      )),
    );
  }
}