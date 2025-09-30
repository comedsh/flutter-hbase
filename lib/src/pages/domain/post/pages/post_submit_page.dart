import 'dart:convert';
import 'dart:io';

import 'package:appbase/appbase.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:mime/mime.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sycomponents/components.dart';
import 'package:image_picker/image_picker.dart';

class PostSubmitPage extends StatefulWidget {
  final int? limit; // 最大上传的个数，默认最大值为 9

  /// TODO 将选中的帖子同步到本地存储中去
  /// TODO 实现模拟的提交
  /// 
  /// TODO 如果新增帖子，应该将 Carousel 的 currentPageIndex 移动到 0？如果要实现的话，还得去控制 Carousel 的 
  ///   pagedController 去设置的同时去修改 CarouselState.currentPageIndex 才行；不过其实没太大必要。
  const PostSubmitPage({
    super.key,
    this.limit = 9,
  });

  @override
  State<PostSubmitPage> createState() => _PostSubmitPageState();
}

class _PostSubmitPageState extends State<PostSubmitPage> {
  final ImagePicker picker = ImagePicker();
  late List<PostSlot> postSlots;
  final placeHolderPostSlot = PostSlot(pic: 'assets/images/transparent-gray.png', width: 640, height: 640);
  int curIndex = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      List<PostSlot> savedPostSlots = await PostSubmitSerializer.load();
      postSlots = savedPostSlots.isEmpty ? [placeHolderPostSlot] : savedPostSlots;
      setState(() => isLoading = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('上传作品')),
      body: Column(
        children: [
          /// SizedBox 解决布局错误：a horizontal viewport was given an unlimited amount of vertical space in which to expand.
          SizedBox(
            height: Screen.height(context) * 0.68,
            child: 
            isLoading 
            ? const Center(child: CircularProgressIndicator())
            : addDeleteButton(
              child: Carousel(
                slots: postSlots,
                onPageChanged: (int index) => curIndex = index,
                imageCreator: (String path, double width, double aspectRatio) { 
                  if (isPlaceholder(path)) {
                    return Image(
                      image: AssetImage(path, package: 'sycomponents'),
                      color: Colors.white30,
                      fit: BoxFit.cover,
                    ); 
                  }
                  else {
                    return Image.file(
                      File(path),
                      errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
                        return const Center(child:Text('This image type is not supported'));
                      },
                      fit: BoxFit.cover
                    );
                  } 
                }, 
                videoCreator: (String videoUrl, String coverImgUrl, double width, double aspectRatio, BoxFit fit) {
                   return CachedVideoPlayer(width: 0, aspectRatio: 9/16, videoUrl: videoUrl, fit: BoxFit.cover,); 
                },
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: sp(22.0)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                /// 从相册添加
                TooltipShowCase(
                  name: 'enterPostSubmitFromAlbum',
                  tooltipText: '点击添加我的作品',
                  popupDirection: TooltipDirection.up,
                  milsecs2DelayRunShowCase: 200,
                  showDurationMilsecs: 3200,
                  arrowTipDistance: 26,
                  learnCount: 1,
                  child: MaterialButton(
                    shape: const CircleBorder(
                      side: BorderSide(
                        width: 1,
                        color: Colors.white30,
                        style: BorderStyle.solid,
                      ),
                    ), // Or Text('Tap')
                    color: Colors.white10,
                    padding: const EdgeInsets.all(12),
                    onPressed: () async {
                      // 注意在我 iPhone 11 ProMax 真机上打开相册是需要花费一小段时间的，因此需要 loading 等待
                      GlobalLoading.show();  
                      try {
                        if (postSlots.length > widget.limit!) {
                          await showAlertDialog(context, content: '已超过最大上传限制，请删除部分帖子', confirmBtnTxt: '确定');
                        } else {
                          final List<XFile> files = await picker.pickMultipleMedia(limit: 9);
                          if (files.isNotEmpty) await addCarouselSlots(files);
                        }
                      } finally {
                        GlobalLoading.close();
                      }
                    },
                    child: const Icon(Ionicons.add, color: Colors.white),
                  ),
                ),
                /// 拍照添加
                SizedBox(
                  /// 奇怪，MaterialButton 似乎默认会占据额外的宽度导致两个按钮相距很远；通过限定第二个 MaterialButton 的宽度
                  /// 就可以调整两个 MaterialButton 之间的间距了；因此下面的这个宽度限制完全是为了调整两个按钮间距用的;
                  /// 最后特别注意的是，下面的这个 width 不要使用 sp 不然小屏幕下会因为宽度不够而导致 icon 会变形
                  width: 50,
                  child: MaterialButton(
                    shape: const CircleBorder(
                      side: BorderSide(
                        width: 1,
                        color: Colors.white30,
                        style: BorderStyle.solid,
                      ),
                    ), // Or Text('Tap')
                    color: Colors.white10,
                    padding: const EdgeInsets.all(12),
                    onPressed: () async {
                      // 注意在我 iPhone 11 ProMax 真机上打开相册是需要花费一小段时间的，因此需要 loading 等待
                      GlobalLoading.show();  
                      try {
                        if (postSlots.length > widget.limit!) {
                          await showAlertDialog(context, content: '已超过最大上传限制，请删除部分帖子', confirmBtnTxt: '确定');
                        } else {
                          /// 再打开的相机中无法切换使用图片或者是视频，无奈只好在打开之前询问下
                          bool isPhoto = await showConfirmDialogWithoutContext(content: '请选择您的拍摄方式', confirmBtnTxt: '拍照', cancelBtnTxt: '录像');
                          XFile? file = isPhoto 
                            ? await picker.pickImage(source: ImageSource.camera, preferredCameraDevice: CameraDevice.rear)
                            : await picker.pickVideo(source: ImageSource.camera, preferredCameraDevice: CameraDevice.rear);
                          if (file != null) await addCarouselSlots([file]);
                        }
                      } finally {
                        GlobalLoading.close();
                      }
                    },
                    child: const Icon(Ionicons.camera_outline, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          GradientElevatedButton(
            width: Screen.width(context) * 0.94,
            gradient: LinearGradient(colors: [
              AppServiceManager.appConfig.appTheme.fillGradientStartColor, 
              AppServiceManager.appConfig.appTheme.fillGradientEndColor
            ]),
            borderRadius: BorderRadius.circular(30.0),
            onPressed: () => null,
            child: Text(
              '上传作品', 
              style: TextStyle(
                fontSize: sp(18), 
                fontWeight: FontWeight.bold, 
                // 强悍，使用下面这个方式设置颜色，就可以自动的感知 light/dark model 的变化了          
                color: Theme.of(context).textTheme.bodyLarge?.color
              )
            )
          ),          
        ],
      ),
    );
  }

  addDeleteButton({required Widget child}) {
    return Stack(
      children: [
        child,
        if (!isInPlaceholderState())
          Positioned(
            top: 16,
            right: 16,
            child: TooltipShowCase(
              name: 'deletePostSubmitPost',
              tooltipText: '点击可删除该图片或视频',
              learnCount: 1,
              milsecs2DelayRunShowCase: 1200,
              showDurationMilsecs: 3200,
              child: GradientElevatedButton(
                gradient: LinearGradient(
                  colors: [Colors.red.shade500, Colors.red.shade900],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight
                ),
                width: sp(80),
                height: sp(32.0),
                borderRadius: BorderRadius.circular(13.0),
                onPressed: () async {
                  var isConfirmed = await showConfirmDialogWithoutContext(
                    content: '确认删除当前图片或视频？', 
                    confirmBtnTxt: '确定', 
                    cancelBtnTxt: '不了'
                  );
                  if (isConfirmed) deleteCurrentCarouselSlot();
                },
                dense: true,
                child: Text('删除', style: TextStyle(color: Colors.white, fontSize: sp(14), fontWeight: FontWeight.bold))
              ),
            ),
          )
      ],
    );
  }

  /// 新增的都是加在队首
  /// 
  /// 为了简化这个 demo 的逻辑，只要小于 limit 都可以追加；但是其实有更严格的限制，即是添加完 [files] 后超过 limit
  /// 怎么办？这个逻辑先放一放了，毕竟只是应对...
  addCarouselSlots(List<XFile> files) async {
    if (postSlots.length < widget.limit!) {
      for (var f in files) {
        /// [lookupMimeType] 通过文件的 header bytes + 后缀名来判断文件的 mimeType；比如输出 image/jpeg 或者 video/mp4
        /// 因此可以通过判断输出的 prefix 是 image/ 还是 video/ 来判断是图片还是视频
        var mimeType = lookupMimeType(f.path); 
        debugPrint("mimeTypeByLookup: $mimeType, mimeTypeByXFile: ${f.mimeType}, path: ${f.path}");
        var isImage = mimeType == null || mimeType.startsWith('image/');
        isImage 
          ? postSlots.insert(0, PostSlot(pic: f.path, width: 0, height: 0))
          : postSlots.insert(0, PostSlot(pic: '', video: f.path, width: 0, height: 0));
      }
      /// 如果用户新添加了 postSlot，那么需要把 placeholder postSlot 给删除
      postSlots.removeWhere((slot) => isPlaceholderPostSlot(slot));
      await PostSubmitSerializer.save(postSlots);      
      /// 因为上述更新视图的逻辑会使用到 async/await，而 setState block 中不允许使用，因此将其放置到上面处理完了以后再发起一次强制更新即可
      setState((){});
    }
    else {
      await showAlertDialog(context, content: '已超过最大上传限制数量，请删除部分帖子', confirmBtnTxt: '确定');
    }
  }

  deleteCurrentCarouselSlot() async {
    debugPrint("deleteCarouselSlot index: $curIndex");
    postSlots.removeAt(curIndex);
    /// 因为当前 slot 被删除了，因此 curIndex 需要回退到上一个 index
    if (curIndex >= 1) curIndex --;
    await PostSubmitSerializer.save(postSlots);
    /// 如果删空了记得把 placeholder 给添加回来
    if (postSlots.isEmpty) {
      postSlots = [placeHolderPostSlot];
    }
    /// 因为上述更新视图的逻辑会使用到 async/await，而 setState block 中不允许使用，因此将其放置到上面处理完了以后再发起一次强制更新即可
    setState((){});
  }
  /// 如果开头是 asserts 开头表明是从 sycomponents 中加载的 placeholder 图片
  bool isPlaceholderPostSlot(PostSlot slot) {
    return isPlaceholder(slot.pic);
  }

  /// 如果开头是 asserts 开头表明是从 sycomponents 中加载的 placeholder 图片
  bool isPlaceholder(String path) {
    return path.startsWith('assets');
  }

  bool isInPlaceholderState() {
    return postSlots.length == 1 && isPlaceholderPostSlot(postSlots[0]);
  }
}

class PostSubmitSerializer {

  // ignore: non_constant_identifier_names
  static String SUBMIT_POST_SLOTS_KEY = 'submitPostSlotsKey';
  // ignore: non_constant_identifier_names
  static String IS_SUBMIT_KEY = 'isSubmitPost';

  static Future<List<PostSlot>> load() async {
    SharedPreferences p = await SharedPreferences.getInstance();
    String? val = p.get(SUBMIT_POST_SLOTS_KEY) as String?;
    debugPrint("PostSubmitSerializer#load, val: $val");
    if (val != null) {
      List<dynamic> objs = jsonDecode(val);
      List<PostSlot> postSlots = objs.map((o) => PostSlot.fromJson(o)).toList();
      return postSlots;
    }
    else {
      return [];
    }
  }

  static save(List<PostSlot> slots) async {
    if (slots.isNotEmpty) {
      SharedPreferences p = await SharedPreferences.getInstance();
      p.setString(SUBMIT_POST_SLOTS_KEY, jsonEncode(slots));
    }
  }

  static append(List<PostSlot> slots) async {
    List<PostSlot> postSlots = await load();
    for (var slot in slots) {
      postSlots.insert(0, slot);
    }
    await save(postSlots);
  }

  static remove(PostSlot slot) async {
    List<PostSlot> postSlots = await load();
    postSlots.removeWhere((sourceSlot) => sourceSlot.pic == slot.pic || sourceSlot.video == slot.video);
    await save(postSlots);
  }

  static bool isSubmitted() {
    throw Exception("not implemented");
  }

}