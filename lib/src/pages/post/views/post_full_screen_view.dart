
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hbase/hbase.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:ionicons/ionicons.dart';
import 'package:sycomponents/components.dart';


final compactFormat = NumberFormat.compact(locale: 'zh_CN');


/// 这是一个满屏展示的 post 页面，实现主要是参考 ins 页面的设计；且因为该组件只是提供给 HBase 系统使用，
/// 因此它的实现粒度范围就围绕着 HBase 系统的需要展开，比如包含喜欢、收藏、关注、下载逻辑等等；然而之所以
/// 将其定义为抽象类是让子系统可以按照自己的需求对某些功能进行定制，比如下载行为等等；
/// 
abstract class PostFullScreenView extends StatelessWidget{
  final Post post;
  /// 通常 [PostFullScreenView] 是在列表中展示，这里的 [postIndex] 即表示该 post 在此列表中的下标
  final int postIndex;

  const PostFullScreenView({
    super.key, 
    required this.post,
    required this.postIndex
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
          child: leftPanel(post)
        ),
        Positioned(
          bottom: sp(42),
          right: sp(20),
          child: rightPanel(post)
        )
      ],
    );
  }

  leftPanel(Post post) {
    /// 使用 SizedBox 限定宽度，这样 text 的 ellipsis overflow 也才会生效
    return SizedBox(
      width: Screen.widthWithoutContext() * 0.7,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // profile avatar
              GestureDetector(
                /// 如果本身就是从 [ProfilePage] 进入的，那么再次点击该用户头像则直接返回即可；
                /// 注意：[Get.previousRoute] 返回的是路径名，因此名字前会有 '/' 符号需要注意
                /// 备注：返回当前 index 的原因是让父组件的 albumList 有能力可以 scrollTo
                onTap: () => Get.previousRoute == "/$ProfilePage"
                  ? Get.back<int>(result: postIndex)
                  : Get.to(() => getProfilePage(post.profile)),
                child: SyCircleAvatar(
                  imgUrl: post.profile.avatar,
                  width: sp(44),
                  height: sp(44),
                  failTextFontSize: sp(9.0),
                ),
              ),
              // profile name
              GestureDetector(
                /// 注释同上
                onTap: () => Get.previousRoute == "/$ProfilePage"
                  ? Get.back<int>(result: postIndex)
                  : Get.to(() => getProfilePage(post.profile)),
                child: Padding(
                  padding: EdgeInsets.only(left: sp(8.0)),
                  child: Text(post.profile.name, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),),
                ),
              ),
              // follow button
              Padding(
                padding: EdgeInsets.only(left: sp(8.0)),
                child: TextButton(
                  onPressed: () {}, 
                  style: TextButton.styleFrom(
                    /// 注意，下面三个参数是用来设置 TextButton 的内部 padding 的，默认的值比较大
                    /// 参考 https://stackoverflow.com/questions/66291836/flutter-textbutton-remove-padding-and-inner-padding
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    padding: EdgeInsets.zero,
                    minimumSize: Size(sp(50), sp(30)),  // 重要：定义按钮的大小
                    /// 设置 text button 的 border                          
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0), // Adjust border radius as needed
                      side: const BorderSide(
                        color: Colors.white, // Color of the border
                        width: 1.0, // Width of the border
                      ),
                    ),
                    backgroundColor: Colors.black12.withOpacity(0.1)
                  ),
                  child: const Text('关注', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),        
            ],
          ),
          SizedBox(height: sp(26)),
          /// 思路是这样的，如果用户点击展开，则 toggle 替换组件
          Caption(post: post, maxLines: 7,)
        ],
      ),
    );
  }

  rightPanel(Post post) {
    return Column(
      children: [
        _likesIconButton(post),
        SizedBox(height: sp(26)),
        _favorIconButton(post),
        SizedBox(height: sp(26)),
        _downloadButton(post)
      ],
    );
  }

  _likesIconButton(Post post) {
    return Column(
      children: [
        Icon(Ionicons.heart_outline, size: sp(30),),
        SizedBox(height: sp(4)),
        Text(compactFormat.format(post.likes)),
      ],
    );
  }

  _favorIconButton(Post post) {
    return Column(
      children: [
        Icon(Ionicons.star_outline, size: sp(30),),
        SizedBox(height: sp(4)),
        Text(compactFormat.format(post.favorites)),
      ],
    );
  }

  /// 将下载后的具体行为抽象出来由子类自行实现
  _downloadButton(Post post) {
    return Column(
      children: [
        Icon(Ionicons.cloud_download_outline, size: sp(30),),
        SizedBox(height: sp(4)),
        const Text('下载'),
      ],
    );
  }

  ProfilePage getProfilePage(Profile profile);

}