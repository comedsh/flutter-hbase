import 'package:appbase/appbase.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hbase/hbase.dart';
import 'package:sycomponents/components.dart';

class PostPageService {

  /// 找到 post 在 posts 中的下标，如果没有找到则返回 null
  static int? getIndex(List<Post> posts, Post post) {
    int index = posts.indexWhere((p) => p.shortcode == post.shortcode);
    /// 如果没有找到则返回 -1 此时需要将其转换为 null
    return index == -1 ? null : index;
  }
}

class PostCarouselService {

  static Widget imageCreator({
    required Post post, 
    required String url,
    required double width, 
    required double aspectRatio
  }) {
    var user = HBaseUserService.user;
    if (!user.isUnlockBlur && post.blur == BlurType.blur) {
        return BlurrableImage(
          blurDepth: post.blurDepth,
          onTap: () => Get.to(() => SalePage(
            saleGroups: AppServiceManager.appConfig.saleGroups,
            initialSaleGroupId: SaleGroupIdEnum.subscr,
            backgroundImage: (AppServiceManager.appConfig as HBaseAppConfig).salePageBackgroundImage,
          )),
          unlockButtonColor: AppServiceManager.appConfig.appTheme.seedColor,
          child: CachedImage(width: width, imgUrl: url, aspectRatio: aspectRatio,),
        );
    } else {
      return CachedImage(width: width, imgUrl: url, aspectRatio: aspectRatio,);
    }    
  }

  static Widget videoCreator({
    required Post post, 
    required String videoUrl, 
    required String coverImgUrl, 
    required double width, 
    required double aspectRatio, 
    required BoxFit fit
  }) {
    var user = HBaseUserService.user;
    if (!user.isUnlockBlur && post.blur == BlurType.blur) {
      return BlurrableVideoPlayer(
        width: width, 
        aspectRatio: aspectRatio,
        videoUrl: videoUrl,
        coverImgUrl: coverImgUrl,
        blurDepth: post.blurDepth, 
        // fit: fit,
        // 默认情况下如果是单 reel 为了让 reel 能够撑满整个屏幕，回调的是 BoxFit.cover，但是正如 [Carousel] 注解中所提到的那样，
        // BoxFit.cover 虽然会撑满整个屏幕但是代价是 reel 会延伸到屏幕之外且试过裁剪，但是在目前 Carousel 的实现下，任何裁剪都是
        // 无效的；因此默认这里返回的是 BoxFit.cover，单它会导致一个问题就是在横向 tab 页面之间切换的时候，比如从"推荐"切换到"欧美"
        // 的过程中，会导致边缘被看到，因为 blur 只会 blur 屏幕内可视部分，超出屏幕部分的无法 blur；因此为了能够实现在任何情况下都
        // 彻底 blur，因此这里将 fit 硬编码维 BoxFit.contain，这样就不会出现上面的问题了。
        fit: BoxFit.contain,
        unlockButtonColor: AppServiceManager.appConfig.appTheme.seedColor,
        onTap: () => Get.to(() => SalePage(
          saleGroups: AppServiceManager.appConfig.saleGroups,
          initialSaleGroupId: SaleGroupIdEnum.subscr,
          backgroundImage: (AppServiceManager.appConfig as HBaseAppConfig).salePageBackgroundImage,
        )),
      );
    } else if (!user.isUnlockBlur && post.blur == BlurType.limitPlay) {
      return DurationLimitableVideoPlayer(
        width: width, 
        aspectRatio: aspectRatio,
        videoUrl: videoUrl, 
        coverImgUrl: coverImgUrl,
        unlockButtonColor: AppServiceManager.appConfig.appTheme.seedColor,
        onTap: () => Get.to(() => SalePage(
          saleGroups: AppServiceManager.appConfig.saleGroups,
          initialSaleGroupId: SaleGroupIdEnum.subscr,
          backgroundImage: (AppServiceManager.appConfig as HBaseAppConfig).salePageBackgroundImage,
        )),
        fit: fit
      );      
    } else {
      return CachedVideoPlayer(
        width: width, 
        aspectRatio: aspectRatio,
        videoUrl: videoUrl,
        coverImgUrl: coverImgUrl,
        fit: fit,
      );      
    }
  }  

}