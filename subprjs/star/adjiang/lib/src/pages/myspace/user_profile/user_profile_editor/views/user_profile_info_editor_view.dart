// ignore_for_file: depend_on_referenced_packages

import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:sycomponents/components.dart';
import 'package:get/get.dart';
import 'package:appbase/appbase.dart';
import 'package:intl/intl.dart';
import 'package:ionicons/ionicons.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../../../../../domain/user/adjiang_user.dart';


/// 仅支持中文、字母、数字、_ 的组合
final usernameValidationRegex = RegExp(r"^[a-zA-Z0-9_\u4e00-\u9fa5]{1,}$");
const List<String> list = <String>['保密', '男生', '女生'];
typedef MenuEntry = DropdownMenuEntry<String>;

class UserProfileInfoEditorView extends StatefulWidget {

  /// 参考 https://docs.flutter.dev/cookbook/forms/validation 实现 form submit
  const UserProfileInfoEditorView({super.key});

  @override
  State<UserProfileInfoEditorView> createState() => UserProfileInfoEditorViewState();
}

class UserProfileInfoEditorViewState extends State<UserProfileInfoEditorView> {
  /// Create a global key that uniquely identifies the Form widget and allows validation of the form.
  /// Note: This is a `GlobalKey<FormState>`, not a GlobalKey<MyCustomFormState>.
  final _formKey = GlobalKey<FormState>();
  static final List<MenuEntry> menuEntries = UnmodifiableListView<MenuEntry>(
    list.map<MenuEntry>((String name) => MenuEntry(value: name, label: name)),
  );
  String? gender;  
  DateTime? birthday;
  String? username;
  String? signature;
  /// 注意，异步错误消息是通过 [TextFormField.forceErrorText] 设置的
  String? forceUsernameValidationMessage;
  bool loading = false;  // 异步检查状态

  @override
  void initState() {
    super.initState();
    var user = (UserService.user as AdJiangUser);
    gender = user.gender ?? list.first;
    birthday = user.birthday;
    username = user.username;
    signature = user.signature;
  }

  @override
  Widget build(BuildContext context) {
    // Build a Form widget using the _formKey created above.     
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// ✅✅用户名 /// 
          Row(
            children: [
              SizedBox(
                width: labelWidth, 
                child: const Align(alignment: Alignment.centerRight, child: Text('用户名：'))
              ),
              SizedBox(
                width: inputFieldWidth,
                child: TextFormField(
                  initialValue: username,
                  forceErrorText: forceUsernameValidationMessage,
                  decoration: InputDecoration(
                    // Customize the underline when the field is enabled (not focused)
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        /// [BorderSide.color] 不能为空且默认的颜色是 const Color(0xFF000000)
                        color: Get.isDarkMode ? Colors.white24 : const Color(0xFF000000),
                        width: 0.1, // Thickness of the underline
                      ),
                    ),
                  ),
                  maxLength: 16,
                  /// The validator receives the text that the user has entered.
                  /// 这里是同步验证，因为异步验证有 debounce 延迟，因此用户可以在这个延迟提交未验证的结果，因此不能仅依靠
                  /// 异步验证；因此通过这里的同步验证，在提交的时候确保语法是正常的。
                  validator: (value) => validateUsernameSyntax(value),
                  /// 唯一的遗憾是 validator 方法不支持异步，因此想到的解决方案就是在 onChange 中实现异步检查
                  onChanged: (value) async {
                    username = value;
                    /// 因为使用了 debounce 因此开启异步验会有延迟，在异步验证结果返回之前用户可以趁这个短的时间内
                    /// 进行提交即可绕过异步检查而提交；不过问题不大，这个时候服务器可以返回对应的错误消息；
                    EasyDebounce.debounce(
                      'usernameRemoteChecking',               // <-- An ID for this particular debouncer
                      const Duration(milliseconds: 600),      // <-- The debounce duration
                      () async {
                        debugPrint('onChanged: $username');
                        await validateUsernameOnChange(username);
                      }
                    );
                  },
                  style: Theme.of(context).textTheme.bodyLarge,  // bodyLarge 也是 TextFormField 的默认值
                  /// 当焦点在该 TextField 中的时候，点击屏幕其它地方 onTapOutside 回调将会被触发，此回调的的作用就是关闭键盘
                  /// Deprecated 会导致其它包含了 TextField 的页面莫名其妙的弹出键盘
                  // onTapOutside: (_) => FocusScope.of(context).unfocus(),
                  /// 当 TextField 允许多行后，键盘的回车键会自动改为换行键，导致键盘无法关闭；下面这一行代码是把换行键改为确定键
                  textInputAction: TextInputAction.done,                  
                ),
              ),
            ],
          ),
          /// ✅✅性别 /// 
          Row(
            children: [
              SizedBox(
                width: labelWidth, 
                child: const Align(alignment: Alignment.centerRight, child: Text('性别：'))
              ),
              DropdownMenu<String>(
                initialSelection: gender ?? list.first,
                onSelected: (String? value) {
                  // This is called when the user selects an item.
                  setState(() {
                    gender = value!;
                  });
                },
                dropdownMenuEntries: menuEntries,
                width: 92,  // 不能低于 90，否则两个字符的选择项文字无法完整展示
                inputDecorationTheme: const InputDecorationTheme(
                  contentPadding: EdgeInsets.all(0),
                  border: OutlineInputBorder(borderSide: BorderSide.none),  // 去掉 Selector 外层的 border
                ),
                textStyle: Theme.of(context).textTheme.bodyLarge,
              ),
            ]
          ),
          /// ✅✅出生日期 /// 
          Row(
            children: [
              SizedBox(
                width: labelWidth, 
                child: const Align(alignment: Alignment.centerRight, child: Text('出生日期：'))
              ),
              Expanded(child: GestureDetector(
                onTap: () async {
                  final DateTime? pickedDate = await showDatePicker(
                    context: context,
                    locale: const Locale.fromSubtags(languageCode: 'zh'),
                    /// 注意，因为保存的是 UTC 时区，因此 birthday 必须 toLocal 否则显示可能会不准确
                    initialDate: birthday?.toLocal() ?? DateTime.now(),
                    firstDate: DateTime(1960),  // 设置能够选择的最小范围
                    lastDate: DateTime.now(),   // 设置能够选择的最大值
                  );
                  if (pickedDate != null) setState(() => birthday = pickedDate);
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      birthday != null
                        /// 注意，因为保存的是 UTC 时区，因此必须 toLocal 否则显示可能会不准确
                        ? DateFormat('yyyy-MM-dd', 'zh_CN').format(birthday!.toLocal())  
                        : '请选择',
                      style: Theme.of(context).textTheme.bodyLarge
                    ),
                    const SizedBox(width: 6),
                    const Icon(Ionicons.create_outline, size: 20,)
                  ],
                ),
              ))
            ],
          ),
          /// ✅✅个性签名 ///
          Row(
            children: [
              SizedBox(
                width: labelWidth, 
                child: const Align(alignment: Alignment.centerRight, child: Text('个性签名：'))
              ),
              SizedBox(
                width: inputFieldWidth,
                child: TextFormField(
                  initialValue: signature,
                  minLines: 1, // can be 1 or more
                  maxLines: 5, // can be 1 or more, or null for unlimited
                  maxLength: 60,
                  onChanged: (value) => signature = value,
                  decoration: InputDecoration(
                    // hintText: '字数不要超过 50 字',s
                    // Customize the underline when the field is enabled (not focused)
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        /// [BorderSide.color] 不能为空且默认的颜色是 const Color(0xFF000000)
                        color: Get.isDarkMode ? Colors.white24 : const Color(0xFF000000),
                        width: 0.1, // Thickness of the underline
                      ),
                    ),
                  ),
                  style: Theme.of(context).textTheme.bodyLarge,  // bodyLarge 也是 TextFormField 的默认值
                  /// 当焦点在该 TextField 中的时候，点击屏幕其它地方 onTapOutside 回调将会被触发，此回调的的作用就是关闭键盘
                  /// Deprecated 会导致其它包含了 TextField 的页面莫名其妙的弹出键盘
                  // onTapOutside: (_) => FocusScope.of(context).unfocus(),
                  /// 当 TextField 允许多行后，键盘的回车键会自动改为换行键，导致键盘无法关闭；下面这一行代码是把换行键改为确定键
                  textInputAction: TextInputAction.done,
                ),
              )
            ]
          ),
          const SizedBox(height: 60),
          /// ✅✅保存/提交 ///
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              __bigButton(text: '保存', width: sp(290), fontSize: 18, clickCallback: () async {
                // Validate returns true if the form is valid, or false otherwise.
                if (_formKey.currentState!.validate() && forceUsernameValidationMessage == null && loading == false) {
                  // If the form is valid, display a snackbar. In the real world,
                  // you'd often call a server or save the information in a database.
                  debugPrint('submitting data');
                  GlobalLoading.show();
                  try {
                    /// API_POST_USER_ADD_INFO -> /u/add/info
                    var r = await dio.post(dotenv.env['API_POST_USER_ADD_INFO']!, data: {
                      'username': username,
                      'gender': gender,
                      'birthday': birthday?.toIso8601String(),
                      'signature': signature
                    });
                    if (r.data['usernameExist'] != null) {
                      setState(() => forceUsernameValidationMessage = r.data['usernameExist']);
                    } else {
                      await showAlertDialogWithoutContext(content: '修改成功', confirmBtnTxt: '确定');
                      Get.back();
                    }
                  } catch(e, stacktrace) {
                    debugPrint('submit get error: $e, stacktrace: $stacktrace');
                    showErrorToast(msg: '网络异常，请稍后再试');
                  } finally {
                    GlobalLoading.close();
                  }
                }
              }),
            ],
          ),
        ],
      ),
    );
  }

  /// 当 [TextFormField] 在 onChange 的过程中即用户输入的过程中就开始验证了，验证包含两个步骤
  /// 1. [validateUsernameSyntax]
  /// 2. [isUsernameExists]，执行这一步的前提是第一步验证通过后
  /// 而为了让错误消息展示的一致性，使用状态参数 [forceUsernameValidationMessage] 注入 [TextFormField.forceErrorText] 的方式回显错误消息
  validateUsernameOnChange(String? username) async {
    var errMessage = validateUsernameSyntax(username);
    debugPrint('errMessage: $errMessage');
    setState(() => forceUsernameValidationMessage = errMessage);
    /// 如果语法验证通过才开始异步检查用户名是否存在
    if (errMessage == null) {
      if (username != null && username.trim() != "") await isUsernameExists(username);
    }
  }

  /// 同步检查用户名是否合法
  String? validateUsernameSyntax(String? username) {
    if (username == null || username.isEmpty) {
      return '用户名不能为空';
    } else if (!usernameValidationRegex.hasMatch(username)) {
      return '仅支持中文、字母、数字、_ 的组合';  
    } else if (username.length < 2) {
      return '用户名需要最少 2 个字符';
    }
    return null;
  }

  /// 异步检查用户名是否重复了
  isUsernameExists(String username) async {
    setState(() {
      loading = true;
      forceUsernameValidationMessage = null;
    });
    try {
      /// API_POST_USER_CHECK_USERNAME_EXIST -> /u/check/username/exist
      var r = await dio.post(dotenv.env['API_POST_USER_CHECK_USERNAME_EXIST']!, data: {'username': username});
      var isExist = r.data['exist'];
      if (isExist) {
        setState(() {
          forceUsernameValidationMessage = '用户名“$username“已经存在，请重新输入';
          loading = false;
        });
      } else {
        setState(() {
          forceUsernameValidationMessage = null;
          loading = false;
        });
      }
    } catch (e, stacktrace) {
      debugPrint('check username exists get error: $e, stacktrace: $stacktrace');
      setState(() => loading = false);  // reset state.
    } 
  }

  Widget __bigButton({
    required String text, 
    required double width, 
    required double fontSize,
    required Function clickCallback,
  }) {
    return GradientElevatedButton(
      width: width,
      gradient: LinearGradient(colors: [
        AppServiceManager.appConfig.appTheme.fillGradientStartColor,
        AppServiceManager.appConfig.appTheme.fillGradientEndColor,
      ]),
      borderRadius: BorderRadius.circular(30.0),
      onPressed: () => clickCallback(),
      child: !loading 
      ? Text(
          text, 
          style: TextStyle(
            fontSize: fontSize, 
            fontWeight: FontWeight.bold, 
            color: Colors.white,
          )
        )
      : SizedBox(width: sp(20), height: sp(20), child: const CircularProgressIndicator(strokeWidth: 2.0,))
    );
  }

  double get labelWidth => sp(100);
  double get inputFieldWidth => sp(280);
}