import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hbase/hbase.dart';
import 'package:sycomponents/components.dart';

/// 一个卡片对应一个 tagCode
class HotspotCardSwiperView extends StatefulWidget {
  final List<String> chnCodes;
  final List<ChannelTag> tags;
  
  const HotspotCardSwiperView({super.key, required this.chnCodes, required this.tags, });

  @override
  State<HotspotCardSwiperView> createState() => _HotspotCardSwiperViewState();
}

class _HotspotCardSwiperViewState extends State<HotspotCardSwiperView> {
  final loading = true.obs;
  late List<List<Profile>> profileGroup;
  @override
  void initState() {
    super.initState();

    /// 远程初始化 profile group
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      var profileGroupPager = HotestPerTagsProfileGroupPager(
        chnCodes: widget.chnCodes,
        tagCodes: widget.tags.map((tag) => tag.code).toList()
      );
      profileGroup = await profileGroupPager.nextPage();
      loading.value = false;
    });    
  }

  @override
  Widget build(BuildContext context) {
    /// viewportFraction 是指该 page 最多能够占用的屏幕的宽度
    final controller = PageController(viewportFraction: 0.8, keepPage: true);

    return SizedBox(
      height: sp(460),
      child: PageView.builder(
        padEnds: false, // 关键，不用在两侧添加 padding
        controller: controller,
        /// 一个 tag 一个卡片，因此 item 的总长度就是 tags 的总长度
        itemCount: widget.tags.length,  
        /// 构建 card 的时候需要注意一点就是 [HotspotCardSwiperView.tags] 和 profileGroup 是顺序上一一对应的，因此可以按照
        /// [index] 来实现一一对应
        itemBuilder: (_, index) {
          var tag = widget.tags[index];
          return Card(
            elevation: 5, // Controls the shadow size
            margin: EdgeInsets.symmetric(horizontal: sp(14), vertical: sp(4)), // Adds margin around the card
            // margin: EdgeInsets.only(left: sp(16), right: sp(8.0), top: sp(4), bottom: sp(4)),
            child: Padding(
              padding: EdgeInsets.all(sp(16.0)),
              child: Column(
                mainAxisSize: MainAxisSize.min, // Make column take minimum height
                children: <Widget>[
                  // title row
                  Row(
                    children: [
                      Text(
                        tag.name,
                        style: TextStyle(fontSize: sp(20), fontWeight: FontWeight.bold),
                      ),
                      // 封装一个 Row 的目的是为了使用 MainAxisAlignment.end 让按钮能够右对齐
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () {  },
                              child: const Text('查看更多'),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 10),
                  /// profile lists
                  Obx(() => loading.value
                    ? const Center(child: CircularProgressIndicator())
                    : profileList(index)
                  ),
                ],
              ),
            ),
          );

        },
      ),
    );
  }

  /// 注意一点就是 [HotspotCardSwiperView.tags] 和 profileGroup 是顺序上一一对应的，因此可以按照
  /// [index] 来实现一一对应
  Widget profileList(int index) {
    var profiles = profileGroup[index];
    return Column(
      children: profiles.map((p) => 
        Row(
          children: [
            ProfileAvatar(profile: p, size: sp(30))
          ],
        )
      ).toList()
    );
  }
}