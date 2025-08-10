
import 'package:flutter/material.dart';
import 'package:hbase/hbase.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:ionicons/ionicons.dart';
import 'package:sycomponents/components.dart';


final compactFormat = NumberFormat.compact(locale: 'zh_CN');


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
          bottom: sp(42),
          left: sp(20),
          child: profileAvatarFollowsPanel(post)
        ),
        Positioned(
          bottom: sp(42),
          right: sp(20),
          child: favLikesAndDownloadsPanel(post)
        )
      ],
    );
  }

  profileAvatarFollowsPanel(Post post) {
    /// 使用 SizedBox 限定宽度，这样 text 的 ellipsis overflow 也才会生效
    return SizedBox(
      width: Screen.widthWithoutContext() * 0.7,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
          ),
          SizedBox(height: sp(26)),
          /// 思路是这样的，如果用户点击展开，则 toggle 替换组件
          captionWidget(post),
          // captionWithScrollTextField(post)
        ],
      ),
    );
  }

  favLikesAndDownloadsPanel(Post post) {
    return Column(
      children: [
        likesIconButton(post),
        SizedBox(height: sp(26)),
        favorIconButton(post),
        SizedBox(height: sp(26)),
        downloadButton(post)
      ],
    );
  }

  likesIconButton(Post post) {
    return Column(
      children: [
        Icon(Ionicons.heart_outline, size: sp(30),),
        SizedBox(height: sp(4)),
        Text(compactFormat.format(post.likes)),
      ],
    );
  }

  favorIconButton(Post post) {
    return Column(
      children: [
        Icon(Ionicons.star_outline, size: sp(30),),
        SizedBox(height: sp(4)),
        Text(compactFormat.format(post.favorites)),
      ],
    );
  }

  downloadButton(Post post) {
    return Column(
      children: [
        Icon(Ionicons.cloud_download_outline, size: sp(30),),
        SizedBox(height: sp(4)),
        const Text('下载'),
      ],
    );
  }

  captionWidget(Post post) {
    return Caption(post: post, maxLines: 7,);
  }

}