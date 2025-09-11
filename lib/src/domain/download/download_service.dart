import 'dart:convert';

import 'package:appbase/appbase.dart';
import 'package:flutter/material.dart';
import 'package:hbase/hbase.dart';
import 'package:sycomponents/components.dart';

class DownloadService {

  /// [loading] 是为测试环境准备的，我发现如果在 Unit test 环境中执行 GlobalLoading.show/clsoe 会报错，目前没有找到解决方案
  /// 为了不影响测试，就先暂时设置这样一个参数在测试环境中禁用 GlobalLoading
  static Future<DownloadStrategy?> getDownloadStrategy(PostType postType, [loading=true]) async {
    try {
      if (loading) GlobalLoading.show();
      var r = await dio.post('/u/download/strategy', data: {
        "postType": postType.name
      });
      var data = r.data;
      debugPrint('downloadStrategy: ${const JsonEncoder.withIndent('  ').convert(data)}');
      var downloadStrategy = DownloadStrategy.fromJson(data['downloadStrategy']);
      if(loading) GlobalLoading.close();
      return downloadStrategy;
    } catch (e, stacktrace) {
      // No specified type, handles all
      debugPrint('Something really unknown throw from ${DownloadService.getDownloadStrategy}: $e, statcktrace below: $stacktrace');
      showErrorToast(msg: '网络异常，请稍后再试');
      // GlobalLoading.close();
      return null;
    }
  }

}