import 'package:flutter/material.dart';
import 'package:hbase/hbase.dart';
import 'package:sycomponents/components.dart';


/// 封装 profile avatar 的初衷是将来能够统一处理 profile 头像的一些特效，比如
/// profile 有更新会有一个小圆点或者是外圆 border 的这样的效果
class ProfileAvatar extends StatelessWidget {
  final Profile profile;
  final double size;
  final Function? onTap;
  const ProfileAvatar({
    super.key, 
    required this.profile, 
    required this.size, 
    this.onTap
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap != null ? onTap!() : null,
      child: SyCircleAvatar(
        imgUrl: profile.avatar,
        width: size,
        failTextFontSize: sp(9.0),
      ),
    );
  }
}