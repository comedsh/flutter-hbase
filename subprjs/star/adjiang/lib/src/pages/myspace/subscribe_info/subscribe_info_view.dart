// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:appbase/appbase.dart';
import 'package:hbase/hbase.dart';
import 'package:sycomponents/components.dart';
import 'package:intl/intl.dart';

import '../constants.dart';

class SubscribeInfoView extends StatefulWidget {
  final bool isDark;
  const SubscribeInfoView({super.key, required this.isDark});

  @override
  State<SubscribeInfoView> createState() => _SubscribeInfoViewState();
}

class _SubscribeInfoViewState extends State<SubscribeInfoView> {
  
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0, // Controls the shadow size
      clipBehavior: Clip.hardEdge,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(MyspacePageConstants.cardBorderRadius), // Adjust radius as needed
      ),
      child: Column(
        children: [
          Container(
            height: sp(36),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: <Color>[
                  Colors.amber.shade900,
                  Colors.amber.shade800,
                  Colors.amber.shade700,
                  Colors.amber.shade500,
                  Colors.amber.shade200,
                ]
              ),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: MyspacePageConstants.cardPaddingSize),
              child: Row(
                children: [
                  Text('VIP 会员', style: TextStyle(fontSize: sp(16), fontWeight: FontWeight.w600, color: Colors.white)),
                ],
              ),
            ),
          ),
          ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: sp(14)),
            // visualDensity: Device.isSmallSizeScreen(context) ? const VisualDensity(horizontal: -2, vertical: -2) : null,
            /// visualDensity 使得 ListTile 的各个元素之间的间距显得更紧凑比如 leading 和 title/subTitle 之间，不像 [dense] 那样将字体缩小，
            /// 这里明显的是调整元素之间的间距
            visualDensity: const VisualDensity(horizontal: -2, vertical: -2),
            dense: Device.isSmallSizeScreen(context),
            leading: leading(),
            title: title(),
            subtitle: subTitle(),
            trailing: bigButton(),
          ),
        ],
      ),
    );
  }

  /// 只有用户未买过会员且有购买会员的 Auth
  Widget? leading() {
    var user = HBaseUserService.user;
    if (!user.hasPurchasedSubscr() && user.isUnlockSubscrSale) {
      return Icon(
        IconFont.icon_sy_huangguan, 
        color: widget.isDark ? const Color.fromARGB(255, 252, 189, 1) : const Color.fromARGB(255, 252, 126, 1),
        size: sp(48.0)
      );
    }
    return null;
  }

  title() {
    var user = HBaseUserService.user;
    if (!user.hasPurchasedSubscr() && user.isUnlockSubscrSale) {
      return Text(
        'VIP', 
        style: TextStyle(
          color: widget.isDark ? Colors.amber[200] : const Color.fromARGB(255, 252, 80, 1), 
          fontSize: sp(22), 
          fontWeight: FontWeight.bold
        ),
      );
    } 
    else if (user.hasPurchasedSubscr()) {
      return Text(
        user.subscr!.title, 
        style: TextStyle(
          color: widget.isDark ? Colors.amber[200] : const Color.fromARGB(255, 252, 80, 1), 
          // color: AppServiceManager.appConfig.appTheme.seedColor,
          fontSize: sp(22), 
          fontWeight: FontWeight.bold
        ),
      );
    }   
  }

  Widget? subTitle() {
    var user = HBaseUserService.user;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!user.hasPurchasedSubscr() && user.isUnlockSubscrSale) 
          Text('解锁会员权限 >', style: TextStyle(color: widget.isDark ? Colors.amber[200] : const Color.fromARGB(255, 252, 80, 1))),
        if (user.hasPurchasedSubscr()) ...subscrDescs(user),
        // if (user.point?.hasPurchasedPoint == true) ...pointDescs(user)
      ],
    );
  }

  List<Widget> subscrDescs(HBaseUser user) {
    /// 备注，start 和 end 都是 utc date，因此直接使用 toLocal 既可以转换成本地时间进行展示
    var subscrStart = user.subscr!.start.toLocal();
    var subscrEnd = user.subscr!.end.toLocal();
    return [
      SizedBox(height: sp(4)),
      Row(
        children: [
          Text('会员有效期', style: TextStyle(color: widget.isDark ? Colors.white38 : Colors.black54)),
          if (user.subscr?.isValid == false) ... [
            SizedBox(width: sp(4)),
            const Text('(已过期)', style: TextStyle(color: Colors.deepOrange))
          ]
        ],
      ),
      SizedBox(height: sp(2)),
      Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(DateFormat('yyyy-MM-dd', 'zh_CN').format(subscrStart), style: TextStyle(fontWeight: FontWeight.bold, fontSize: sp(14))),
          SizedBox(width: sp(2)),
          Text(DateFormat('HH:mm').format(subscrStart), style: TextStyle(fontSize: sp(8.0))),
          SizedBox(width: sp(2)), 
          const Text('-'),
          SizedBox(width: sp(2)),
          Text(DateFormat('yyyy-MM-dd', 'zh_CN').format(subscrEnd), style: TextStyle(fontWeight: FontWeight.bold, fontSize: sp(14))),
          SizedBox(width: sp(2)),
          Text(DateFormat('HH:mm').format(subscrEnd), style: TextStyle(fontSize: sp(8.0))),
        ],
      ),
      /// 只有当用户处于有效订阅的情况下才展示条款，因为条款可能会发生变化，过期后的会员发现会员期间没有享受到变化的内容，可能会投诉；
      if (user.subscr?.isValid == true) 
        ... [
          Divider(thickness: 0.5, color: widget.isDark ? Colors.white24 : Colors.black12),
          Text('会员权益', style: TextStyle(color: widget.isDark ? Colors.white38 : Colors.black54)),
          SizedBox(height: sp(2)),
          BulletList(
            items: user.subscr!.ruleDescs,
            bulletSize: sp(12), 
            fontSize: sp(14),
            fontColor: widget.isDark ? null : Colors.black87,
            bulletPaddingLeft: sp(4), 
            textPaddingLeft: sp(6),
            rowPaddingBottom: 0
          ),
        ]
    ];
  }  

  /// BigButton 展示逻辑非常的简单，unlockSubscrSale 的展示优先级高于 unlockPointSale 
  Widget? bigButton() {
    var user = HBaseUserService.user;
    /// 优先展示会员的展示方式
    /// 三种方式：立即开通，升级订阅，更换订阅
    /// 显示逻辑也非常的简单，因为怎么展示都是由后台的 Authorities 进行配置的，因此展示逻辑如下所述，
    /// 1. 如果用户有 unlockSubscrSale 权限或者 unlockNonRenewingSubscrSale 那么展示“立即开通“
    /// 2. 如果用户只有 unlockAdvancedSubscrSale 那么展示“升级订阅”（后台配置可以确保普通有效订阅权限中才包含，因此确保了只有有效期内会员才可以）
    bool isSubscrible = user.isUnlockSubscrSale || user.isUnlockAdvancedSubscrSale || user.isUnlockNonRenewingSubscrSale;
    if (isSubscrible) {
      var text = user.isUnlockSubscrSale || user.isUnlockNonRenewingSubscrSale ? '立即开通': '升级订阅';
      return __bigButton(
        text: text, 
        width: sp(128.0), 
        fontSize: sp(16.0), 
        clickCallback: () => Get.to(() => SalePage(
          saleGroups: AppServiceManager.appConfig.saleGroups,
          backgroundImage: (AppServiceManager.appConfig as HBaseAppConfig).salePageBackgroundImage,
        ))
      );
    }
    return null;
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
  
}