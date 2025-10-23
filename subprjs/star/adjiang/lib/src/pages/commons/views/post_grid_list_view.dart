// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:hbase/hbase.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:sycomponents/components.dart';
import 'package:appbase/appbase.dart';
import 'package:get/get.dart';

class PostGridListView extends StatefulWidget {
  final Pager<Post> postPager;
  const PostGridListView({super.key, required this.postPager});

  @override
  State<PostGridListView> createState() => _PostGridListViewState();
}

class _PostGridListViewState extends State<PostGridListView> {

  @override
  void initState() {
    super.initState();
    initPageController();
  }

  initPageController() {
    pagingController = PagingController(
      firstPageKey: 1, 
      /// invisibleItemsThreshold 当滑动到还剩下多少个不可见 items 的时候加载下一页，默认是 3 个
      /// 备注：之前这个值设置为了 6，结果初始情况下就会加在 2 页；因此我怀疑，在 [PostAlbumListView] 中是不是按照行数来计算的？
      invisibleItemsThreshold: 3
    );
    // 监听分页回调，注意参数 pageKey 就是 PageNum，只是该值现在由框架维护了，干脆直接将 pageKey 更名为 pageNum
    // 特别注意的是，第一次页面初始化会自动触发该回调加载第一页内容
    pagingController.addPageRequestListener((pageNum) async {
      debugPrint('pagingController trigger the nextPage event with pageNum: $pageNum');
      await Paging.nextPage(pageNum, widget.postPager, pagingController, context);
      // removedRevantPostsFromBlockedProfiles();
      if (pageNum != 1) UserService.sendReloadUserEvent();
    });
  }  

  /// 注意，后台是从 1 开始分页的，因此这里务必设置为 1
  PagingController<int, Post> pagingController = PagingController(firstPageKey: 1);

  @override
  Widget build(BuildContext context) {
    return PagedMasonryGridView.count(
      // 解决 [PostGridListView] 的 items 太少导致 Pull Refresh（下拉更新）不会被触发的问题，参考
      // https://stackoverflow.com/questions/57519765/refresh-indicator-doesnt-work-when-list-doesnt-fill-the-whole-page
      physics: const AlwaysScrollableScrollPhysics(),      
      pagingController: pagingController,
      crossAxisCount: 2,  // 设置多少列
      mainAxisSpacing: 6,  // 设置纵向两个元素间间隔
      crossAxisSpacing: 8,  // 设置横向两个元素间间隔
      builderDelegate: PagedChildBuilderDelegate<Post>( 
        itemBuilder: (context, post, index) => cellBuilder(post),
        firstPageProgressIndicatorBuilder: (_) => const RefreshProgressIndicator()
      )
    );
  }

  Widget cellBuilder(Post post) {
    var coverImg = post.slots[0];  // 使用第一个 slot image 作为封面
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,  // 左对齐
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(16.0)),
          child: PostCoverService.attachBadgedIcon(
            post: post, 
            img: CachedImage(width: coverImg.width, aspectRatio: coverImg.width / coverImg.height, imgUrl: coverImg.pic), 
            isPaintPinned: false
          )
        ),
        Padding(
          padding: const EdgeInsets.all(6.0),
          child: Column(
            /// 为了保证整个组件不越界，在 Row 组件上添加了 SingleChildScrollView 控件，但是它会破坏默认的 start 布局；因此这里必须强制约束
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                post.captionRaw ?? "",
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                softWrap: true
              ),
              Padding(
                padding: EdgeInsets.only(top: sp(12), left: sp(6), right: sp(6)),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      // 1) profile avatar and name
                      GestureDetector(
                        onTap: () => Get.to(() => ProfilePage(profile: post.profile)),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            ProfileAvatar(
                              profile: post.profile, 
                              size: sp(28), 
                              onTap: () => Get.to(() => ProfilePage(profile: post.profile)) 
                            ),
                            SizedBox(width: sp(8)),
                            SizedBox(
                              width: sp(96),
                              child: Text(
                                post.profile.name, 
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                // softWrap: true,                            
                                style: TextStyle(fontSize: sp(13), fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),
                      /// 点赞喜欢
                      StatefulLikeButton(post: post, isVertical: false, iconSize: sp(22), fontSize: sp(13),),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}