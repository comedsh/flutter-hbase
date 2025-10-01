

// ignore_for_file: depend_on_referenced_packages

import 'package:appbase/appbase.dart';
import 'package:flutter/material.dart';
import 'package:hbase/hbase.dart';
import 'package:sycomponents/components.dart';

class HQJGuanAppConfig extends HBaseAppConfig {

  /// Below singleton
  HQJGuanAppConfig._internal();

  static final HQJGuanAppConfig _instance = HQJGuanAppConfig._internal();

  factory HQJGuanAppConfig() {
    return _instance;
  }

  @override
  String get appName => '环球景观';

  @override
  String get beianNum => 'demo123456';

  @override
  String get platformCode => 'nature';

  @override
  String get sysCode => 'hqjguan';
  
  @override
  AppTheme get appTheme => DemoAppTheme();
  
  @override
  String get appStoreId => '6752983105';
  
  @override
  Widget get salePageBackgroundImage {
    if (AppServiceManager.appConfig.i) {
      return const Image(image: AssetImage('images/sale_page_bg_i.jpg'));
    }
    else {
      return HBaseUserService.user.isUnlockSubscrSale 
        ? Device.isSmallSizeScreenWithoutContext() 
          ? const Image(image: AssetImage('images/sale_page_bg_s_small.png'))
          : const Image(image: AssetImage('images/sale_page_bg_s.png'))
        : const Image(image: AssetImage('images/sale_page_bg_p.png'));

    }
  }

}

class DemoAppTheme extends AppTheme {

  @override
  ThemeData get darkTheme => ThemeData.dark();

  @override
  ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: seedColor),
  );

  /// 这个值是以 deepPurple 为 seed color 不断微调出来的，感觉比较舒服的一个颜色
  @override
  Color get borderGradientStartColor => const Color.fromARGB(255, 214, 165, 223);  

  @override
  Color get borderGradientEndColor => Colors.purpleAccent;

  @override
  Color get fillGradientStartColor => Colors.purple.shade200;

  @override
  Color get fillGradientEndColor => Colors.deepPurple;
  
  @override
  Color get seedColor => Colors.deepPurple;

}