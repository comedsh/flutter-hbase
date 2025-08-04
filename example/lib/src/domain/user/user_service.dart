import 'package:appbase/appbase.dart';
import 'package:flutter/material.dart';

import 'user.dart';


class DemoUserService extends UserService {

  /// 使用了私有构造函数，这样外部无法初始化实例了，外部只能通过工厂方法构造实例了
  DemoUserService._internal();

  static final DemoUserService _instance = DemoUserService._internal();

  /// 通过工厂方法 + 私有构造函数构造出单例模式
  factory DemoUserService() {
    return _instance;
  }

  /// 覆盖父类的关键扩展方法以提供自己的 User 解析逻辑
  @override
  Future<DemoUser> parseUser(Map<String, dynamic> userData) async {
    var user = DemoUser.fromJson(userData);
    debugPrint('parseUser() get user: ${user.toJson()}');
    return user;
  }

}

