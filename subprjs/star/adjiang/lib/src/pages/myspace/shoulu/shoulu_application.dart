// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hbase/hbase.dart';
import 'package:sycomponents/components.dart';
import 'package:appbase/appbase.dart';

class ShouluApplication extends StatefulWidget {
  const ShouluApplication({super.key});

  @override
  State<ShouluApplication> createState() => _ShouluApplicationState();
}

class _ShouluApplicationState extends State<ShouluApplication> {
  late String name;
  String? igId;
  late String reason;

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('收录申请'),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 36),
        child: applilcationForm(),
      )
    );
  }

  Form applilcationForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// ✅✅博主名字
          Row(
            children: [
              SizedBox(
                width: labelWidth, 
                child: const Align(alignment: Alignment.centerRight, child: Text('博主名字：'))
              ),
              SizedBox(
                width: inputFieldWidth,
                child: TextFormField(
                  decoration: InputDecoration(
                    // Customize the underline when the field is enabled (not focused)
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        /// [BorderSide.color] 不能为空且默认的颜色是 const Color(0xFF000000)
                        color: Get.isDarkMode ? Colors.white24 : const Color(0xFF000000),
                        width: 0.1, // Thickness of the underline
                      ),
                    ),
                    hintText: '（必填）',
                    hintStyle: Theme.of(context).textTheme.bodyMedium,
                  ),
                  maxLength: 20,
                  onChanged: (value) => name = value,
                  /// The validator receives the text that the user has entered.
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '用户名不能为空';
                    } 
                    return null;
                  },
                  style: Theme.of(context).textTheme.bodyLarge,  // bodyLarge 也是 TextFormField 的默认值
                ),
              ),
            ],
          ),
          /// ✅✅IG id ///
          Row(
            children: [
              SizedBox(
                width: labelWidth, 
                child: const Align(alignment: Alignment.centerRight, child: Text('IG id：'))
              ),
              SizedBox(
                width: inputFieldWidth,
                child: TextFormField(
                  decoration: InputDecoration(
                    // Customize the underline when the field is enabled (not focused)
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        /// [BorderSide.color] 不能为空且默认的颜色是 const Color(0xFF000000)
                        color: Get.isDarkMode ? Colors.white24 : const Color(0xFF000000),
                        width: 0.1, // Thickness of the underline
                      ),
                    ),
                    hintText: '（选填）',
                    hintStyle: Theme.of(context).textTheme.bodyMedium,
                  ),
                  maxLength: 50,
                  onChanged: (value) => igId = value,
                  /// The validator receives the text that the user has entered.
                  style: Theme.of(context).textTheme.bodyLarge,  // bodyLarge 也是 TextFormField 的默认值
                ),
              ),
            ],
          ),
          /// ✅✅申请理由 ///
          Row(
            children: [
              SizedBox(
                width: labelWidth, 
                child: const Align(alignment: Alignment.centerRight, child: Text('收录理由：'))
              ),
              SizedBox(
                width: inputFieldWidth,
                child: TextFormField(
                  minLines: 1, // can be 1 or more
                  maxLines: 5, // can be 1 or more, or null for unlimited
                  maxLength: 100,
                  // onChanged: (value) => signature = value,
                  decoration: InputDecoration(
                    // hintText: '字数不要超过 50 字',
                    // Customize the underline when the field is enabled (not focused)
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        /// [BorderSide.color] 不能为空且默认的颜色是 const Color(0xFF000000)
                        color: Get.isDarkMode ? Colors.white24 : const Color(0xFF000000),
                        width: 0.1, // Thickness of the underline
                      ),
                    ),
                    hintText: '（必填）越详细越容易被收录哦...',
                    hintStyle: Theme.of(context).textTheme.bodyMedium,
                  ),
                  style: Theme.of(context).textTheme.bodyLarge,  // bodyLarge 也是 TextFormField 的默认值
                  onChanged: (value) => reason = value,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '收录请求不能为空';
                    } else if (value.length < 10) {
                      return '收录请求不能少于 10 个字';
                    }
                    return null;
                  },
                ),
              )
            ]
          ),
          SizedBox(height: sp(66)),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GradientElevatedButton(
                width: Screen.width(context) * 0.45,
                height: 40,
                gradient: LinearGradient(colors: [
                  AppServiceManager.appConfig.appTheme.fillGradientStartColor,
                  AppServiceManager.appConfig.appTheme.fillGradientEndColor,
                ]),
                borderRadius: BorderRadius.circular(30.0),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    try {
                      GlobalLoading.show();
                      await dio.post('/u/shoulu/apply', data: {
                        'name': name,
                        'igId': igId,
                        'reason': reason
                      });
                      if (UserService.user.isUnSubscribing()) {
                        var isConfirmed = await showConfirmDialogWithoutContext(
                          title: "加速审核",
                          content: "加入会员可尊享极速审核，最快 24 小时内可完成收录，是否加入会员？",
                          confirmBtnTxt: '去加入',
                          cancelBtnTxt: '不了'
                        );
                        if (isConfirmed) {
                          await Get.to(() => SalePage(
                            saleGroups: AppServiceManager.appConfig.saleGroups,
                            backgroundImage: (AppServiceManager.appConfig as HBaseAppConfig).salePageBackgroundImage,
                          ));
                        }
                        await showAlertDialogWithoutContext(content: '收录申请已提交');
                        Get.back();
                      }
                    } catch(e, stacktrace) {
                      debugPrint("shoulu apply, $e, $stacktrace");
                      showErrorToast(msg: '提交失败；网络超时，请稍后重试！');
                    } finally {
                      GlobalLoading.close();
                    }
                  }                    
                },
                child: Text(
                    '提交', 
                    style: TextStyle(
                      fontSize: sp(18), 
                      fontWeight: FontWeight.bold, 
                      color: Colors.white,
                    )
                  )
              )
            ],
          )
        ],
      ),
    );
  }


  double get labelWidth => sp(100);
  double get inputFieldWidth => sp(280);

}