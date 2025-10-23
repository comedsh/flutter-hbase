
import 'dart:async';

import 'package:appbase/appbase.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import 'package:sycomponents/components.dart';

/// 签名上不要写 mock
class JuBao extends StatefulWidget {
  const JuBao({super.key});

  @override
  State<JuBao> createState() => _JuBaoState();
}

class _JuBaoState extends State<JuBao> {
  String? _checkVal = '1';

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showModalBottomSheet<void>(
        isDismissible: true,
        // 重要属性，默认 bottom sheet 高度只能是 534，使用 scroll 避免溢出
        isScrollControlled: true,
        context: context,
        builder: (BuildContext context) {
          // 注意，模态窗口必须使用 StatefulBuilder + setModalState 进行状态改变，否则模态窗口不会响应变化
          return StatefulBuilder(
            builder: (BuildContext context, StateSetter setModalState) {
              return TitleContentBox(
                gradient: Get.isDarkMode 
                ? null 
                : LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.purple.shade50, Colors.white54]
                  ),
                title: '举报',
                body: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    RadioListTile(title: const Text('低俗'), value: '1', groupValue: _checkVal, onChanged: (val) => setModalState(() => _checkVal = val)),
                    RadioListTile(title: const Text('引战'), value: '2', groupValue: _checkVal, onChanged: (val) => setModalState(() => _checkVal = val)),
                    RadioListTile(title: const Text('刷屏'), value: '3', groupValue: _checkVal, onChanged: (val) => setModalState(() => _checkVal = val)),
                    RadioListTile(title: const Text('人身攻击'), value: '4', groupValue: _checkVal, onChanged: (val) => setModalState(() => _checkVal = val)),
                    RadioListTile(title: const Text('违规违法'), value: '5', groupValue: _checkVal, onChanged: (val) => setModalState(() => _checkVal = val)),
                    RadioListTile(title: const Text('垃圾广告'), value: '6', groupValue: _checkVal, onChanged: (val) => setModalState(() => _checkVal = val)),
                    RadioListTile(title: const Text('内容不相关'), value: '7', groupValue: _checkVal, onChanged: (val) => setModalState(() => _checkVal = val)),
                    const Divider(thickness: 1.0),
                    SizedBox(height: sp(12)),
                    GradientElevatedButton(
                      gradient: LinearGradient(colors: [
                        AppServiceManager.appConfig.appTheme.fillGradientStartColor,
                        AppServiceManager.appConfig.appTheme.fillGradientEndColor
                      ]),
                      width: sp(200),
                      height: sp(42.0),
                      borderRadius: BorderRadius.circular(30.0),
                      onPressed: () { 
                        GlobalLoading.show();
                        Timer(Duration(milliseconds: Random.randomInt(1200, 3600)), () async { 
                          GlobalLoading.close();
                          await showAlertDialog(context, content: '举报成功！', confirmBtnTxt: '关闭');
                          Get.back();  // 关闭模态窗口
                        });
                      },
                      child: Text('举报', style: TextStyle(color: Colors.white, fontSize: sp(18), fontWeight: FontWeight.bold),)),
                    SizedBox(height: sp(40)),
                  ],
                ),
              );
            }
          );
        }
      ),
      child: Column(
        children: [
          /// 因为举报 icon 只会在 [PostFullScreenView] 页面中展示，因此固定为白色
          Icon(Ionicons.alert_circle_outline, size: sp(30), color: Colors.white,),
          SizedBox(height: sp(4)),
          /// 因为举报 icon 只会在 [PostFullScreenView] 页面中展示，因此固定为白色
          Text('举报', style: TextStyle(fontSize: sp(14), color: Colors.white)),
        ],
      ),
    );
  }
}
