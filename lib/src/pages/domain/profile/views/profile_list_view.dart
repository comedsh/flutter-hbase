import 'package:appbase/appbase.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hbase/hbase.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:sycomponents/components.dart';

class ProfileListView extends StatefulWidget {
  final Pager<Profile> pager;
  const ProfileListView({super.key, required this.pager});

  @override
  State<ProfileListView> createState() => _ProfileListViewState();
}

class _ProfileListViewState extends State<ProfileListView> {
  final PagingController<int, Profile> pagingController = PagingController(firstPageKey: 1);
  bool dark = false;

  @override
  void initState() {
    super.initState();
    dark = Get.isDarkMode;
    /// 监听分页回调，注意参数 pageKey 就是 PageNum，只是该值现在由框架维护了，干脆直接将 pageKey 更名为 pageNum
    /// 唯一需要特别注意的是 PagingController 会自动触发第一页的加载，因此无需手动的去触发第一页加载；
    pagingController.addPageRequestListener((pageNum) async {
      debugPrint('pagingController trigger the nextPage event with pageNum: $pageNum');
      await Paging.nextPage(pageNum, widget.pager, pagingController, context);
      removePostsFromBlockedProfiles();
      if (pageNum != 1) UserService.sendReloadUserEvent();
    });
    listenEvents();
  }

  @override
  void dispose() {
    EventBus().off(themeChangedHandler);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async { 
        await HapticFeedback.heavyImpact();  // 给一个震动反馈。
        await pullRefresh();
      },
      child: Card(
        elevation: 20, // Controls the shadow size
        shadowColor: Colors.black,
        margin: EdgeInsets.only(left: sp(14), right: sp(14)),
        child: PagedListView<int, Profile>(
          pagingController: pagingController,
          builderDelegate: PagedChildBuilderDelegate<Profile>(
            itemBuilder: (context, profile, index) => Container(
              decoration: BoxDecoration(
                // 注意因为 index 从 0 开始，因此要使得间隔第二行出现跳色，那么是计算的是奇数才对
                color: !dark 
                  ? index % 2 != 0 ? Colors.grey.shade200 : null
                  : null,
                borderRadius: const BorderRadius.all(Radius.circular(12.0),),
              ),              
              child: Padding(
                // padding: EdgeInsets.symmetric(vertical: sp(7), horizontal: sp(4)),
                padding: EdgeInsets.all(sp(8.0)),
                child: Row(
                  children: [
                    /// 头像
                    ProfileAvatar(profile: profile, size: sp(64), onTap: () {
                        Get.to(() => ProfilePage(profile: profile));
                        ScoreService.notifyScoreSimple();
                    }),
                    SizedBox(width: sp(8)),
                    /// 名字和描述
                    GestureDetector(
                      onTap: () {
                        Get.to(() => ProfilePage(profile: profile));
                        ScoreService.notifyScoreSimple();
                      },
                      child: SizedBox(
                        width: Screen.width(context) * 0.53,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(profile.name, style: TextStyle(fontWeight: FontWeight.w500, fontSize: sp(16))),
                            Text(
                              profile.description ?? "",
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
                      profile: profile, 
                      followButtonCreator: ({required bool loading, required onTap}) => 
                        GradientElevatedButton(
                          gradient: LinearGradient(colors: [
                            AppServiceManager.appConfig.appTheme.fillGradientEndColor,
                            AppServiceManager.appConfig.appTheme.fillGradientEndColor
                          ]),
                          width: sp(80),
                          height: sp(32.0),
                          borderRadius: BorderRadius.circular(13.0),
                          onPressed: () => onTap(context),
                          dense: true,
                          child: loading
                          ? SizedBox(width: sp(14), height: sp(14), child: const CircularProgressIndicator(strokeWidth: 1.0, color: Colors.white))
                          : Text('关注', style: TextStyle(color: Colors.white, fontSize: sp(14), fontWeight: FontWeight.bold))
                        ),
                      cancelFollowButtonCreator: ({required bool loading, required onTap}) => 
                        TextButton(
                          onPressed: () => onTap(context), 
                          style: TextButton.styleFrom(
                            /// 注意，下面三个参数是用来设置 TextButton 的内部 padding 的，默认的值比较大
                            /// 参考 https://stackoverflow.com/questions/66291836/flutter-textbutton-remove-padding-and-inner-padding
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            padding: EdgeInsets.zero,
                            minimumSize: Size(sp(80), sp(32)),  // 重要：定义按钮的大小
                            /// 设置 text button 的 border                          
                            backgroundColor: Colors.black12.withOpacity(0.1)
                          ),
                          child: loading 
                            ? SizedBox(width: sp(14), height: sp(14), child: const CircularProgressIndicator(strokeWidth: 1.5, color: Colors.white54))
                            : Text('已关注', style: TextStyle(fontSize: sp(14), color: Colors.white54)),
                        ),                  
                    )
                  ],
                ),
              ),
            ),
            // 加载第一页时候的使用的 loading 组件
            firstPageProgressIndicatorBuilder: (context) => const Center(child: CircularProgressIndicator()),
            // 直接使用 pagingController.refresh 即可重新触发 firstPageProgressIndicatorBuilder 的 loading 过程
            firstPageErrorIndicatorBuilder: (context) => FailRetrier(callback: pagingController.refresh),
            // 如果加载下一页失败后使用的 reloading 组件
            newPageErrorIndicatorBuilder: (context) => 
              NewPageErrorIndicator(
                errMsg: '网络异常，点击重试',
                onTap: () => pagingController.retryLastFailedRequest()),
            // 第一页就没有数据时候所使用的组件
            noItemsFoundIndicatorBuilder: (context) => const Center(child: Text('没有数据'),),
        
          ),
        ),
      ),
    );
  }

  listenEvents() {
    HBaseStateManager hbaseState = Get.find();
    ever(hbaseState.blockProfileEvent, (Profile? p) async {
      debugPrint('block profile event received, block profile: ${p?.code}');
      removePostsFromBlockedProfiles();
      if(context.mounted) setState((){});
    });
    EventBus().on(EventConstants.themeChanged, themeChangedHandler);
  }

  /// 核心就是 [pagingController.refresh] 会触发 [pagingController.addPageRequestListener] 然后立刻调用 [nextPage]
  /// 后去加载第一页数据；其背后逻辑是，[pagingController.refresh] 中会调用语句 `pagingController.itemList = null` 导致
  /// [pagingController.addPageRequestListener] 被触发
  pullRefresh() {
    widget.pager.reset();
    pagingController.refresh();
  }  

  removePostsFromBlockedProfiles() async {
    final blockedProfiles = await BlockProfileService.getAllBlockedProfiles();
    pagingController.itemList?.removeWhere((p) => blockedProfiles.contains(p));
  }

  themeChangedHandler(isDark) => setState(() => dark = isDark);
}