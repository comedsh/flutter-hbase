// ignore_for_file: depend_on_referenced_packages

import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:sycomponents/components.dart';
import 'package:get/get.dart';

import 'widget/user_profile_birthday_editor_widget.dart';
import 'package:appbase/appbase.dart';


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
  /// 
  final _formKey = GlobalKey<FormState>();

  static final List<MenuEntry> menuEntries = UnmodifiableListView<MenuEntry>(
    list.map<MenuEntry>((String name) => MenuEntry(value: name, label: name)),
  );

  String dropdownValue = list.first;  

  @override
  Widget build(BuildContext context) {
    // Build a Form widget using the _formKey created above.     
    return Form(
      key: _formKey,
      child: Column(
        // Add TextFormFields and ElevatedButton here.
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(
                width: labelWidth, 
                child: const Align(alignment: Alignment.centerRight, child: Text('用户名：'))
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
                  ),
                  /// The validator receives the text that the user has entered.
                  /// TODO https://pub.dev/packages/async_textformfield 弥补 [TextFormField] 不支持 async/await 
                  ///   相关讨论：https://stackoverflow.com/questions/53194662/flutter-async-validator-of-textformfield
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '用户名不能为空';
                    }
                    else if (value.length < 2) {
                      return '用户名需要最少 2 个字符';
                    }
                    return null;
                  },
                  style: Theme.of(context).textTheme.bodyLarge,  // bodyLarge 也是 TextFormField 的默认值
                ),
              ),
            ],
          ),
          Row(
            children: [
              SizedBox(
                width: labelWidth, 
                child: const Align(alignment: Alignment.centerRight, child: Text('性别：'))
              ),
              DropdownMenu<String>(
                initialSelection: list.first,
                onSelected: (String? value) {
                  // This is called when the user selects an item.
                  setState(() {
                    dropdownValue = value!;
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
          Row(
            children: [
              SizedBox(
                width: labelWidth, 
                child: const Align(alignment: Alignment.centerRight, child: Text('出生日期：'))
              ),
              const Expanded(child: AdJiangDatePicker())
            ],
          ),
          Row(
            children: [
              SizedBox(
                width: labelWidth, 
                child: const Align(alignment: Alignment.centerRight, child: Text('个性签名：'))
              ),
              SizedBox(
                width: inputFieldWidth,
                child: TextFormField(
                  minLines: 1, // can be 1 or more
                  maxLines: 5, // can be 1 or more, or null for unlimited
                  maxLength: 100,
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
                  ),
                  style: Theme.of(context).textTheme.bodyLarge,  // bodyLarge 也是 TextFormField 的默认值
                ),
              )
            ]
          ),
          const SizedBox(height: 60),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              __bigButton(text: '保存', width: sp(290), fontSize: 18, clickCallback: () {
                // Validate returns true if the form is valid, or false otherwise.
                if (_formKey.currentState!.validate()) {
                  // If the form is valid, display a snackbar. In the real world,
                  // you'd often call a server or save the information in a database.
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Processing Data')),
                  );
                }
              }),
            ],
          ),
        ],
      ),
    );
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
      onPressed: () {
        clickCallback();
      },
      child: Text(
        text, 
        style: TextStyle(
          fontSize: fontSize, 
          fontWeight: FontWeight.bold, 
          color: Colors.white,
        )
      )
    );
  }  

  double get labelWidth => sp(100);
  double get inputFieldWidth => sp(280);
}