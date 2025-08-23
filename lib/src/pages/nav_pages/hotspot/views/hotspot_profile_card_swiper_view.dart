import 'package:appbase/appbase.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hbase/hbase.dart';
import 'package:hbase/src/pages/nav_pages/hotspot/pages/hotspot_profile_list_view_page.dart';
import 'package:sycomponents/components.dart';

/// 一个卡片对应一个 tagCode
/// 改页面借用了 [PageView] 来进行构建，其中通过 [PageController.viewportFraction] 来控制每一个 [PageView] 的大小
/// 并且一个 PageView 中就是一个 Card
class HotspotProfileCardSwiperView extends StatefulWidget {
  final List<String> chnCodes;
  final List<ChannelTag> tags;
  
  const HotspotProfileCardSwiperView({super.key, required this.chnCodes, required this.tags, });

  @override
  State<HotspotProfileCardSwiperView> createState() => _HotspotProfileCardSwiperViewState();
}

class _HotspotProfileCardSwiperViewState extends State<HotspotProfileCardSwiperView> {
  var loading = true;
  var hasError = false;
  late List<List<Profile>> profileGroup;
  @override
  void initState() {
    super.initState();

    /// 远程初始化 profile group
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await initProfileGroup();
    });    
  }

  @override
  Widget build(BuildContext context) {
    /// viewportFraction 是指该 page 最多能够占用的屏幕的宽度
    final controller = PageController(viewportFraction: 0.8, keepPage: true);
    
    return SizedBox(
      height: sp(500),
      child: PageView.builder(
        // 关键，不用在 Card 的两侧额外添加 padding；如果不设置为 false，第一张 Card 会居中展示；
        padEnds: false, 
        controller: controller,
        /// 一个 tag 一个卡片，因此 item 的总长度就是 tags 的总长度
        itemCount: widget.tags.length,  
        /// 构建 card 的时候需要注意一点就是 [HotspotCardSwiperView.tags] 和 profileGroup 是顺序上一一对应的，因此可以按照
        /// [index] 来实现一一对应
        itemBuilder: (_, index) {
          var tag = widget.tags[index];
          return Card(
            elevation: 5, // Controls the shadow size
            margin: EdgeInsets.symmetric(horizontal: sp(14)), // Adds margin between cards
            /// 使用 SingleChildScrollView 的目的是为了避免在小尺寸屏幕上可能会越界的问题
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: sp(14.0)),
                child: Column(
                  mainAxisSize: MainAxisSize.max, // Make column take minimum height
                  children: [
                    // title row
                    titleRow(tag),
                    // 注意，又学到一招，可以直接在 [] 中写 if/else；还是因为三元表达式中不支持 ...array 的写法，否则报错；示例如下，
                    // 之前的写法是 loading ? CircularProgressIndicator : ...profileList(index)，结果 ...profileList<index>
                    // 的位置报错，编译不过去；看来是三元表达式不支持；改成 if/else 就可以了。
                    // 参考：https://medium.com/@mjawwadiqbal22/how-to-spread-a-list-in-dart-flutter-triple-dot-spread-operators-guide-tips-73041aa57853
                    if (loading == false && hasError == false) 
                      ...profileList(index)
                    else if (loading == true) 
                      SizedBox(height: sp(300), child: const Center(child: CircularProgressIndicator()))
                    else if (loading == false && hasError == true)
                      SizedBox(
                        height: sp(300),
                        child: NewPageErrorIndicator(
                          errMsg: '网络异常，点击重试',
                          onTap: () async {
                            setState((){
                              loading = true;
                              hasError = false;
                            });
                            await initProfileGroup();                                
                          }),
                      )
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  initProfileGroup() async {
    try {
      var profileGroupPager = HotestPerTagsProfileGroupPager(
        chnCodes: widget.chnCodes,
        tagCodes: widget.tags.map((tag) => tag.code).toList(),
        pageSize: 7
      );
      profileGroup = await profileGroupPager.nextPage();
      setState(() {
        loading = false;
        hasError = false;
      });
    } catch (e, stacktrace) {
      // No specified type, handles all
      debugPrint('Something really unknown throw from $HotspotProfileCardSwiperView.nextPage: $e, statcktrace below: $stacktrace');
      setState(() {
        loading = false;
        hasError = true;
      });
    }    
  }

  titleRow(ChannelTag tag) {
    return Row(
      children: [
        Text(
          tag.name,
          style: TextStyle(fontSize: sp(20), fontWeight: FontWeight.bold),
        ),
        // 封装一个 Row 的目的是为了能够使用 MainAxisAlignment.end 让按钮能够右对齐
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                ),
                onPressed: () => Get.to(() => HotspotProfileListViewPage(
                  title: tag.name,
                  chnCodes: widget.chnCodes,
                  tagCodes: [tag.code],
                )),
                child: Text('查看更多', style: TextStyle(
                  fontSize: sp(16), 
                  fontWeight: FontWeight.w500,
                  decoration: TextDecoration.underline, 
                  decorationThickness: 0.5,
                  decorationStyle: TextDecorationStyle.wavy
                ),),
              ),
            ],
          ),
        )
      ],
    );
  }

  /// 注意一点就是 [HotspotProfileCardSwiperView.tags] 和 profileGroup 是顺序上一一对应的，因此可以按照
  /// [index] 来实现一一对应
  List<Widget> profileList(int index) {
    var profiles = profileGroup[index];
    return profiles.map((p) => 
      Padding(
        padding: EdgeInsets.symmetric(vertical: sp(7)),
        child: SingleChildScrollView(
          /// 添加横向滑动是为了彻底解决小尺寸屏幕下越界的问题；备注：添加了这个横向滑动后，在模拟器上不太好
          /// 通过滑动切换 card 了，但是在真机上问题不大，只要稍微滑动快一些即可，因此不影响使用
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              /// avatar
              GestureDetector(
                onTap: () => Get.to(() => ProfilePage(profile: p)),
                child: ProfileAvatar(profile: p, size: sp(50))
              ),
              SizedBox(width: sp(8)),
              /// 名字和描述
              GestureDetector(
                onTap: () => Get.to(() => ProfilePage(profile: p)),
                child: SizedBox(
                  width: Screen.width(context) * 0.41,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(p.name, style: TextStyle(fontWeight: FontWeight.w500, fontSize: sp(16))),
                      Text(
                        p.description ?? "",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: sp(13))
                      )
                    ],
                  ),
                ),
              ),
              SizedBox(width: sp(8.0)),
              /// follow button
              StatefulFollowButton(
                profile: p, 
                followButtonCreator: ({required bool loading, required onTap}) => 
                  GradientElevatedButton(
                    gradient: LinearGradient(colors: [
                      AppServiceManager.appConfig.appTheme.fillGradientEndColor,
                      AppServiceManager.appConfig.appTheme.fillGradientEndColor
                    ]),
                    width: sp(48),
                    height: sp(25.0),
                    borderRadius: BorderRadius.circular(13.0),
                    onPressed: () => onTap(context),
                    dense: true,
                    child: loading
                    ? SizedBox(width: sp(12), height: sp(12), child: const CircularProgressIndicator(strokeWidth: 1.0, color: Colors.white))
                    : Text('关注', style: TextStyle(color: Colors.white, fontSize: sp(12), fontWeight: FontWeight.bold))
                  ),
                cancelFollowButtonCreator: ({required bool loading, required onTap}) => 
                  TextButton(
                    onPressed: () => onTap(context), 
                    style: TextButton.styleFrom(
                      /// 注意，下面三个参数是用来设置 TextButton 的内部 padding 的，默认的值比较大
                      /// 参考 https://stackoverflow.com/questions/66291836/flutter-textbutton-remove-padding-and-inner-padding
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      padding: EdgeInsets.zero,
                      minimumSize: Size(sp(50), sp(30)),  // 重要：定义按钮的大小
                      /// 设置 text button 的 border                          
                      backgroundColor: Colors.black12.withOpacity(0.1)
                    ),
                    child: loading 
                      ? SizedBox(width: sp(12), height: sp(12), child: const CircularProgressIndicator(strokeWidth: 1.5, color: Colors.white54))
                      : Text('已关注', style: TextStyle(fontSize: sp(12), color: Colors.white54)),
                  ),                  
              ),
            ],
          ),
        ),
      )
    ).toList();
  }

}
