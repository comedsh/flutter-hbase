// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:hbase/hbase.dart';
import 'package:sycomponents/components.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:get/get.dart';
import '../core/adjiang_appconfig.dart';
import 'commons/services/page_service.dart';
import 'package:sypages/pages.dart' hide TabData;
import 'package:appbase/appbase.dart';

import 'myspace/shoulu/shoulu_application.dart';
import 'skeleton.dart';


class AdJiangScaffold extends StatefulWidget {
  final Widget child;
  /// 提供自定义的 appbar actions
  final List<Widget>? actions;
  /// 通过调用 `Scaffold.of(context).openEndDrawer()` 唤醒
  final Widget? endDrawer; 
  const AdJiangScaffold({super.key, required this.child, this.actions, this.endDrawer});

  @override
  State<AdJiangScaffold> createState() => _AdJiangScaffoldState();
}

class _AdJiangScaffoldState extends State<AdJiangScaffold> {

  bool _isDark = false;

  @override
  void initState() {
    super.initState();
    _isDark = Get.isDarkMode;
    EventBus().on(EventConstants.themeChanged, themeChangedHandler);
  }

  @override
  void dispose() {
    super.dispose();
    EventBus().off(EventConstants.themeChanged, themeChangedHandler);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // title: const Text('爱豆酱'),
        title: _isDark 
          // ? const Image(image: AssetImage('images/logo_font_transparent.png'), width: 72)
          ? const Image(image: AssetImage('images/logo_font_colored.png'), width: 72)
          : const Image(image: AssetImage('images/logo_font_colored.png'), width: 72),
        centerTitle: false,
        automaticallyImplyLeading: false,
        elevation: 4.0,
        actions: widget.actions ?? defautlActions
      ),
      body: widget.child,
      /// 通过调用 [Scaffold.of(context).openEndDrawer()] 可以打开
      endDrawer: widget.endDrawer,
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
        searchResultPageCreator: (String keyword) => searchProfileResultPageCreator(
          keyword: keyword, 
          chnCodes: (AppServiceManager.appConfig.display as HBaseDisplay).chnCodes,
          noResultFoundCallbackBuidler: (context) => Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(onPressed: () => Get.to(() => const ShouluApplication()), child: const Text('收录申请')),
              const Text('没有数据'),
            ]
          )
        ),
        isShowSearchResultDuringInput: true,
        hintText: (AppServiceManager.appConfig.display as AdJiangDisplay).searchHintText,  // TODO configure this.
      ))
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

  themeChangedHandler(isDark) => setState(() => _isDark = isDark);    
}