
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
    // convert post slots to carousel slots
    List<Slot> slots = [];  // Carousel slots
    for (var slot in post.slots) {
      slots.add(Slot(width: post.width, height: post.height, picUrl: slot.pic, videoUrl: slot.video));
    }
    return Column(
      children: [
        /// 模仿抖音，除了直播以外其它的图片、视频的播放都会让开 status bar 的空间；
        // SizedBox(height: Screen.statusBarHeight(context)),
        Expanded(
          child: Container(
            alignment: Alignment.center,
            child: createPostPage(slots)
          ),
        ),
      ],
    );
  }

  createPostPage(List<Slot> slots) {
    return Stack(
      children: [
        AutoKnockDoorShowCaseCarousel(slots: slots),
        Positioned(
          bottom: sp(50),
          left: sp(20),
          child: profileAvatarFollowsPanel(post)
        )
      ],
    );
  }

  profileAvatarFollowsPanel(Post post) {
    return Row(
      children: [
        SyCircleAvatar(
          imgUrl: post.profile.avatar,
          width: sp(44),
          height: sp(44),
          failTextFontSize: sp(9.0),
        ),
        Padding(
          padding: EdgeInsets.only(left: sp(8.0)),
          child: Text(post.profile.name, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),),
        ),
        Padding(
          padding: EdgeInsets.only(left: sp(8.0)),
          child: TextButton(
            onPressed: () {}, 
            style: TextButton.styleFrom(
              /// 注意，下面三个参数是用来设置 TextButton 的内部 padding 的，默认的值比较大
              /// 参考 https://stackoverflow.com/questions/66291836/flutter-textbutton-remove-padding-and-inner-padding
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              padding: EdgeInsets.zero,
              minimumSize: Size(sp(50), sp(30)),
              /// 设置 text button 的 border                          
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0), // Adjust border radius as needed
                side: const BorderSide(
                  color: Colors.white, // Color of the border
                  width: 1.0, // Width of the border
                ),
              ),
              // You can also customize other properties like foregroundColor, backgroundColor, etc.
              // foregroundColor: Colors.blue, // Text color
              // backgroundColor: Colors.transparent, // Background color
              backgroundColor: Colors.black12.withOpacity(0.1)
            ),           
            child: const Text('关注', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
          ),
        ),        
      ],
    );
  }

}