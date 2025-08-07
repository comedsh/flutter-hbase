
import 'package:flutter/material.dart';
import 'package:hbase/hbase.dart';
import 'package:sycomponents/components.dart';

/// 这是一个满屏展示的 post 页面，实现主要是参考 ins 页面的设计；然而之所以将其定义为抽象类
/// 是让子系统可以按照自己的需求对其进行定制
abstract class FullScreenPostPage extends StatelessWidget{
  final Post post;

  const FullScreenPostPage({
    super.key, 
    required this.post,
  });

  @override
  Widget build(BuildContext context) {
    var alignment = post.type == PostType.reel ? Alignment.topCenter : Alignment.center;
    // convert post slots to carousel slots
    List<Slot> slots = [];  // Carousel slots
    for (var slot in post.slots) {
      slots.add(Slot(width: post.width, height: post.height, picUrl: slot.pic, videoUrl: slot.video));
    }
    return Column(
      children: [
        /// 模仿抖音，除了直播以外其它的图片、视频的播放都会让开 status bar 的空间；
        SizedBox(height: Screen.statusBarHeight(context)),
        Expanded(
          child: Container(
            alignment: alignment,
            child: AutoKnockDoorShowCaseCarousel(slots: slots)
          ),
        ),
      ],
    );
  }

}