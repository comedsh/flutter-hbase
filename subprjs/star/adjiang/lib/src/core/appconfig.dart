

// ignore_for_file: depend_on_referenced_packages

import 'package:appbase/appbase.dart';
import 'package:flutter/material.dart';
import 'package:hbase/hbase.dart';

class AdJiangAppConfig extends HBaseAppConfig {

  /// Below singleton
  AdJiangAppConfig._internal();

  static final AdJiangAppConfig _instance = AdJiangAppConfig._internal();

  factory AdJiangAppConfig() {
    return _instance;
  }

  @override
  String get appName => '爱豆酱';

  @override
  String get beianNum => 'demo123456';

  @override
  String get platformCode => 'stars';

  @override
  String get sysCode => 'adjiang';
  
  @override
  AppTheme get appTheme => DemoAppTheme();
  
  @override
  String get appStoreId => '6752983105';
  
  @override
  Widget get salePageBackgroundImage {
      return const Image(image: AssetImage('images/sale_page_bg.jpg'));
  }

}

class DemoAppTheme extends AppTheme {

  @override
  ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorSchemeSeed: seedColor,
    tabBarTheme: TabBarTheme(labelColor: seedColor),
  );
  
  @override
  ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: seedColor),
    tabBarTheme: TabBarTheme(labelColor: seedColor),
  );

  /// 这个值是以 deepPurple 为 seed color 不断微调出来的，感觉比较舒服的一个颜色
  @override
  Color get borderGradientStartColor => Colors.red.shade200;  

  @override
  Color get borderGradientEndColor => Colors.redAccent;

  @override
  Color get fillGradientStartColor => Colors.red.shade300;

  @override
  Color get fillGradientEndColor => seedColor;
  
  @override
  Color get seedColor => Colors.red;

}