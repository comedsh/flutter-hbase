// ignore_for_file: curly_braces_in_flow_control_structures

import 'package:flutter/material.dart';
import 'package:hbase/hbase.dart';
import 'package:sycomponents/components.dart';

class HotspotPostCardSwiperView extends StatefulWidget {
  final List<String> chnCodes;
  const HotspotPostCardSwiperView({super.key, required this.chnCodes});

  @override
  State<HotspotPostCardSwiperView> createState() => _HotspotPostCardSwiperViewState();
}

class _HotspotPostCardSwiperViewState extends State<HotspotPostCardSwiperView> {
  /// viewportFraction 是指该 [PageView] 单个 page 最多能够占用的屏幕的宽度
  final controller = PageController(viewportFraction: 0.8, keepPage: true);
  var loading = true;
  var hasError = false;
  late List<Post> posts;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async => await loadHotPosts());
    super.initState();
  }

  loadHotPosts() async {  
    try {      
      var postPager = ChannelTagPostPager(
        chnCodes: widget.chnCodes, 
        tagCodes: null, 
        isReelOnly: false, 
        /// 特别特别注意，这里必须使用 24 个，因为它的 http get query 和分类页面的一样，前端框架会缓存，因此
        /// 如果这里设置为了 12，那么会导致分类页面直接从缓存中取得 12 个元素进而导致无法分页了。
        pageSize: 24, 
        pageLabel: PageLabel.hotestPage,
      );
      posts = await postPager.nextPage();
      setState(() {
        loading = false;
        hasError = false;
      });
    } catch (err, stacktrace) {
      debugPrint('err: $err, stacktrace: $stacktrace');
      setState(() {
        loading = false;
        hasError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: cardHeight,
      child: PageView.builder(
        // 关键，不用在 Card 的两侧额外添加 padding；如果不设置为 false，第一张 Card 会居中展示；
        padEnds: false, 
        controller: controller,      
        /// 构建 card 的时候需要注意一点就是 [HotspotCardSwiperView.tags] 和 profileGroup 是顺序上一一对应的，因此可以按照
        /// [index] 来实现一一对应
        itemBuilder: (_, index) {
          return Card(
            clipBehavior: Clip.hardEdge,  // 务必设置，否则填充的图片视频的 border 圆角会失败
            elevation: 5, // Controls the shadow size
            margin: EdgeInsets.only(right: cardMarginRight), // Adds margin between cards
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0), // Adjust radius as needed
            ),
            child: loading 
            ? const Center(child: CircularProgressIndicator(strokeWidth: 2.0,))
            : hasError 
              ? NewPageErrorIndicator(
                errMsg: '网络异常，点击重试',
                onTap: () async {
                  setState((){
                    loading = true;
                    hasError = false;
                  });
                  await loadHotPosts();
              })
              : createPostCard(posts[index], index)

          );
        }
      ),
    );
  }

  Widget createPostCard(Post post, int index) {
    return Stack(
      children: [
        _createCarousel(post),
        Positioned(
          left: sp(16),
          bottom: sp(30),
          child: SimplePorifleIntroPanel(postIndex: index, post: post)
        )
      ]
    );
  }

  Widget _createCarousel(Post post) {
    return AutoKnockDoorShowCaseCarousel(
      slots: post.slots, 
      indicatorPaddingBottom: 10, 
      imageCreator: (String url, double width, double aspectRatio) => 
        PostCarouselService.imageCreator(
          post: post, 
          url: url, 
          width: width, 
          aspectRatio: aspectRatio
        ) ,
      videoCreator: (String videoUrl, String coverImgUrl, double width, double aspectRatio, BoxFit fit) =>
        PostCarouselService.videoCreator(
          post: post, 
          videoUrl: videoUrl, 
          coverImgUrl: coverImgUrl, 
          width: width, 
          aspectRatio: cardWidth / cardHeight,
          // 特别注意：不能设置为 cover，否则向上拖拽的时候，视频会溢出出 Card 
          fit: BoxFit.contain,
        ),
    );
  }

  double get pageWidth => Screen.width(context) * 0.8;

  double get cardMarginRight => sp(14.0);

  double get cardWidth => pageWidth - cardMarginRight;
  
  double get cardHeight => sp(420.0);

}