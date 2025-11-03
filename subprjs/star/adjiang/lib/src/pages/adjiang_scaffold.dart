// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:hbase/hbase.dart';
import 'package:sycomponents/components.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:get/get.dart';
import '../core/appconfig.dart';
import 'commons/services/page_service.dart';
import 'package:sypages/pages.dart' hide TabData;
import 'package:appbase/appbase.dart';

import 'skeleton.dart';


class AdJiangScaffold extends StatelessWidget {
  final Widget child;
  /// 提供自定义的 appbar actions
  final List<Widget>? actions;
  /// 通过调用 `Scaffold.of(context).openEndDrawer()` 唤醒
  final Widget? endDrawer; 
  const AdJiangScaffold({super.key, required this.child, this.actions, this.endDrawer});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('爱豆酱'),
        centerTitle: false,
        automaticallyImplyLeading: false,
        elevation: 4.0,
        actions: actions ?? defautlActions
      ),
      body: child,
      /// 通过调用 [Scaffold.of(context).openEndDrawer()] 可以打开
      endDrawer: endDrawer,
    );
  }

  List<Widget> get defautlActions => [
    AdJiangPageService.darkModeSwicher,
    IconButton(
      icon: const Icon(FeatherIcons.search), 
      onPressed: () => Get.to(() => SearchBarInAppBar(
        appBarAutomaticallyImplyLeading: true,
        isEmptyFocusToShowKeywordListPage: false,
        flashPageCreator: (TextEditingController controller) => flashPageCreator(controller),
        // keywordsListPageCreator: (TextEditingController controller) => searchKeywordListPage(controller),
        searchResultPageCreator: (String keyword) => 
          searchProfileResultPageCreator(keyword: keyword, chnCodes: (AppServiceManager.appConfig.display as HBaseDisplay).chnCodes),
        isShowSearchResultDuringInput: true,
        hintText: (AppServiceManager.appConfig.display as AdJiangDisplay).searchHintText,  // TODO configure this.
        )
      )
    ),
    // 会员皇冠，如果已经是会员了则跳转到会员中心页
    IconButton(
      icon: Icon(
        IconFont.icon_sy_huangguan, 
        // color: const Color.fromARGB(255, 252, 189, 1),
        color: const Color.fromARGB(255, 252, 126, 1),
        size: sp(32)
      ),
      onPressed: () => UserService.user.isUnSubscribing()
        ? Get.to(() => SalePage(
            saleGroups: AppServiceManager.appConfig.saleGroups,
            backgroundImage: (AppServiceManager.appConfig as HBaseAppConfig).salePageBackgroundImage,
          ))
        : EventBus().emit(NAV_TO_PAGE_EVENT, 4), // 4 是 MeHome Page index.
    )
  ];
}