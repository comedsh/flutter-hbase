import 'package:appbase/appbase.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:sycomponents/components.dart';

class PostSubmitPage extends StatefulWidget {
  const PostSubmitPage({super.key});

  @override
  State<PostSubmitPage> createState() => _PostSubmitPageState();
}

class _PostSubmitPageState extends State<PostSubmitPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('上传作品')),
      body: Column(
        children: [
          /// SizedBox 解决布局错误：a horizontal viewport was given an unlimited amount of vertical space in which to expand.
          SizedBox(
            height: Screen.height(context) * 0.68,
            child: Carousel(
              slots: [
                PostSlot(pic: 'assets/images/transparent-gray.png', width: 640, height: 640)
              ],
              imageCreator: (String url, double width, double aspectRatio) { 
                return const Image(
                  image: AssetImage("assets/images/transparent-gray.png", package: 'sycomponents'),
                  color: Colors.white30,
                  fit: BoxFit.cover,
                ); 
              }, 
              videoCreator: (String videoUrl, String coverImgUrl, double width, double aspectRatio, BoxFit fit) { return Container(); },
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: sp(22.0)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                MaterialButton(
                  shape: const CircleBorder(
                    side: BorderSide(
                      width: 1,
                      color: Colors.white30,
                      style: BorderStyle.solid,
                    ),
                  ), // Or Text('Tap')
                  color: Colors.white10,
                  padding: const EdgeInsets.all(12),
                  onPressed: () {},
                  child: const Icon(Ionicons.add, color: Colors.white),
                ),
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
                    onPressed: () {},
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
}