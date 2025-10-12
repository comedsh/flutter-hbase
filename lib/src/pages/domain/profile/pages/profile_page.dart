import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hbase/hbase.dart';
import 'package:hbase/src/pages/domain/profile/views/profile_statistics_intro_panel.dart';
import 'package:sycomponents/components.dart';

typedef PostAlbumListCreator = PostAlbumListView Function({
  required Pager<Post> post, 
  required OnCellTapped cellClickCallback
});

class ProfilePage extends StatelessWidget {
  final Profile profile;
  const ProfilePage({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    var tabDatas = [ 
      TabData(id: 'hot', name: '热门'), 
      TabData(id: 'latest', name: "最新", isDefault: true)
    ];
    return Scaffold(
      appBar: AppBar(
        title: Text(profile.name),
        actions: [
          MenuAnchor(
            style: MenuStyle(
              elevation: WidgetStateProperty.all<double>(8.0),
              /// 默认弹出的 menuItemButton 的右侧明显要宽于左侧，且右侧的距离不是 padding，无奈为了快速调整样式，只能调整
              /// 左侧的 padding，刚好 12 能够对其，注意这个值是所有屏幕下的标准值不需要 sp
              padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
                const EdgeInsets.only(left: 12.0, right: 0),
              ),              
            ),
            builder: (BuildContext context, MenuController controller, Widget? child) {
              return IconButton(
                onPressed: () {
                  if (controller.isOpen) {
                    controller.close();
                  } else {
                    controller.open();
                  }
                },
                icon: const Icon(Icons.more_horiz),
              );
            },
            menuChildren: [
              MenuItemButton(
                onPressed: () async {
                  var isConfirmed = await showConfirmDialogWithoutContext(content: '确定拉黑该用户？', confirmBtnTxt: '确定', cancelBtnTxt: '不了');
                  if (isConfirmed) {
                    GlobalLoading.show('拉黑中，请稍后...');
                    Timer(Duration(milliseconds: Random.randomInt(800, 2800)), () async {
                      await BlockProfileService.block(profile);
                      HBaseStateService.triggerBlockProfileEvent(profile);
                      GlobalLoading.close();
                      Get.back();
                      showInfoToast(msg: '数据已清理', location: ToastLocation.CENTER);
                    });
                  }
                },
                child: const Text('拉黑'),
              )
            ]
          )
        ],
      ),
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget> [
            SliverToBoxAdapter(child: ProfileStatisticsIntroPanel(profile: profile))
          ];
        }, 
        body: TabBarViewBodyPage(
          tabs: tabDatas,
          initialIndex: TabService.getDefaultIndex(tabDatas),
          tabBarViewContentBuilder: (BuildContext context, TabData tab) {
            var postPager = ProfilePostPager(profileCode: profile.code, sortBy: tab.id, pageSize: 24);
            return PostAlbumListView(
              postPager: postPager, 
              onCellTapped: (posts, post, postPager) async =>
                /// 当点击 cell 后会跳转到第三方页面，这里的返回值 index 是从第三方页面返回时的 post index，
                /// 这样 PostAlbumListView 根据这个值就可以进行 scrollTo 操作了
                await Get.to<int>(() => 
                  PostFullScreenListViewPage(
                    posts: posts, 
                    post: post, 
                    postPager: postPager,
                    title: post.profile.name,
                    isShowUploadTs: tab.id == 'latest',
                  ))
            );
          },
        )
      )
    );
  }
}