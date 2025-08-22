import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hbase/hbase.dart';
import 'package:sycomponents/components.dart';

typedef AwareLoadingButtonCreator = Widget Function({
  required bool loading,
  required Function(BuildContext context) onTap
});


class StatefulFollowButton extends StatefulWidget {
  final Profile profile;
  /// 添加关注按钮
  final AwareLoadingButtonCreator followButtonCreator;
  /// 取消关注按钮
  final AwareLoadingButtonCreator cancelFollowButtonCreator;
  
  const StatefulFollowButton({
    super.key, 
    required this.profile, 
    required this.cancelFollowButtonCreator,    
    required this.followButtonCreator, 
  });

  @override
  State<StatefulFollowButton> createState() => _StatefulFollowButtonState();
}

class _StatefulFollowButtonState extends State<StatefulFollowButton> {

  var loading = false.obs;

  @override
  void initState() {
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    return Obx(() =>
      widget.profile.isFollowed 
        ? widget.cancelFollowButtonCreator(loading: loading.value, onTap: onTap)
        : widget.followButtonCreator(loading: loading.value, onTap: onTap),
    );
  }

  onTap(BuildContext context) async {
    // 如果当前状态是已经关注了，则取消关注
    if (widget.profile.isFollowed) {
      var isConfirmed = await showConfirmDialog(
        context,
        content: '确认取消关注？',
        confirmBtnTxt: '是的',
        cancelBtnTxt: '不了'
      );
      if (isConfirmed) {
        try {
          loading.value = true;
          await Sleep.sleep(milliseconds: 3000); // 本地测试模拟 loading
          await HbaseUserService.disFollow(widget.profile.code);
          widget.profile.isFollowed = false;
        } catch (e, stacktrace) {
          // No specified type, handles all
          debugPrint('Something really unknown throw from disFollow: $e, statcktrace below: $stacktrace');
        } finally {
          loading.value = false;
        }
      }
    }
    // 如果未关注，则关注
    else {
      try {
        loading.value = true;
        await Sleep.sleep(milliseconds: 3000); // 本地测试模拟 loading
        await HbaseUserService.follow(widget.profile.code);
        widget.profile.isFollowed = true;
      } catch (e, stacktrace) {
        // No specified type, handles all
        debugPrint('Something really unknown throw from disFollow: $e, statcktrace below: $stacktrace');
      } finally {
        loading.value = false;
      }
    }
  }
}