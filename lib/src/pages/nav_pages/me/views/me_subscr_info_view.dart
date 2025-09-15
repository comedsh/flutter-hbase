import 'package:appbase/appbase.dart';
import 'package:flutter/material.dart';
import 'package:flutter_font_icons/flutter_font_icons.dart';
import 'package:get/get.dart';
import 'package:hbase/hbase.dart';
import 'package:sycomponents/components.dart';

class MeSubscrInfoView extends StatefulWidget {
  const MeSubscrInfoView({super.key});

  @override
  State<MeSubscrInfoView> createState() => _MeSubscrInfoViewState();
}

class _MeSubscrInfoViewState extends State<MeSubscrInfoView> {

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: sp(14)),
        leading: leading(),
        title: title(),
        subtitle: subTitle(),
        trailing: bigButton(),
      ),
    );
  }

  /// 展示皇冠的情况有两种
  /// 1. 非有效期订阅会员用户但是开启了 unlockSubscr ，
  /// 2. 有效期内的用户
  /// 其它情况通通展示普通用户 icon
  Widget? leading() {
    var user = HBaseUserService.user;
    if (user.isSubscribing() || (user.isUnSubscribing() && user.isUnlockSubscrSale) ) {
      return Icon(
        IconFont.icon_sy_huangguan, 
        color: const Color.fromARGB(255, 252, 189, 1),
        size: sp(48.0)
      );
    }
    else {
      return Icon(
        FontAwesome.user,
        color: AppServiceManager.appConfig.appTheme.seedColor,
        size: sp(48.0)
      );
    }
  }

  /// title 部分用于展示用户的身份信息，
  /// 1. 未购买过会员且有 unlockSubscrSale 权限的展示 "VIP"
  /// 2. 凡是购买过会员的则展示会员的 title
  /// 除了上述的情况都展示为 “游客“
  Widget? title() {
    var user = HBaseUserService.user;
    if (!user.hasPurchasedSubscr() && user.isUnlockSubscrSale) {
      return Text(
        'VIP', 
        style: TextStyle(
          color: Colors.amber[200], 
          fontSize: sp(22), 
          fontWeight: FontWeight.bold
        ),
      );
    }
    if (user.hasPurchasedSubscr()) {
      return Text(
        user.subscr!.title, 
        style: TextStyle(
          color: Colors.amber[200], 
          fontSize: sp(22), 
          fontWeight: FontWeight.bold
        ),
      );
    }
    // 其它情况通通展示普通用户；但是想了想展示“普通用户”或者“游客”都不好，还不如直接展示应用名称
    return Text(
      AppServiceManager.appConfig.appName,
      style: TextStyle(
        color: Colors.amber[200], 
        fontSize: sp(22), 
        fontWeight: FontWeight.bold
      ),
    );
  }

  /// 包含两个部分，一个是会员相关的展示部分，一个是积分相关的展示部分
  /// 1 会员相关部分
  ///   1.1 如果未购买过会员
  ///       如果开启了 unlockSubscrSale 则显示"解锁会员权益 >"字样，否则不展示
  ///   1.2 如果购买过会员
  ///       展示会员有效期并展示会员条款  
  /// 
  /// 一个是会员的有效期和会员条款，另外一个是积分
  Widget? subTitle() {
    var user = HBaseUserService.user;
    if (!user.hasPurchasedSubscr() && user.isUnlockSubscrSale) {
      return Text('解锁会员权限 >', style: TextStyle(color: Colors.amber[200]),);
    }
    if (user.hasPurchasedSubscr()) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('会员有效期', style: TextStyle(color: Colors.white30, fontSize: sp(13))),
          const Text('2001-01-01:05:03 至 2001-09-01:05:03'),
          Text('会员权益', style: TextStyle(color: Colors.white30, fontSize: sp(13))),
          ... user.subscr!.ruleDescs.map((desc) => Text(desc)),
          Text('积分概要', style: TextStyle(color: Colors.white30, fontSize: sp(13))),
        ],
      );
    }
    return null;
  }

  /// BigButton 展示逻辑非常的简单，unlockSubscrSale 的展示优先级高于 unlockPointSale 
  Widget? bigButton() {
    var user = HBaseUserService.user;
    if (user.isUnlockSubscrSale) {
      return __bigButton(
        text: '立即开通', 
        width: sp(144.0), 
        fontSize: sp(16.0), 
        clickCallback: () => Get.to(() => SalePage(saleGroups: AppServiceManager.appConfig.saleGroups,))
      );
    }
    else if (user.isUnlockPointSale) {
      return __bigButton(
        text: '购买积分', 
        width: sp(144.0), 
        fontSize: sp(16.0), 
        clickCallback: () => Get.to(() => SalePage(saleGroups: AppServiceManager.appConfig.saleGroups,))
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
        Colors.amberAccent[100]!, 
        Colors.amber[600]!
        // AppServiceManager.appConfig.appTheme.fillGradientStartColor, 
        // AppServiceManager.appConfig.appTheme.fillGradientEndColor
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
          // 强悍，使用下面这个方式设置颜色，就可以自动的感知 light/dark model 的变化了          
          // color: Theme.of(context).textTheme.bodyLarge?.color
          color: AppServiceManager.appConfig.appTheme.seedColor,
        )
      )
    );
  }

  @Deprecated('已经被 ListTile 取代')
  Widget tradeListTile({
    Widget? leading,
    Widget? title,
    Widget? subTitle,
    Widget? bigButton,
  }) {
    return Card(
      // margin: const EdgeInsets.all(0.0),  // 消除默认两边的 margin
      child: Padding(
        padding: EdgeInsets.only(top: sp(16.0), bottom: sp(16.0)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
              children: [ leading ?? Container() ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [ title ?? Container() ],
                ),
                Row(
                  children: [ subTitle ?? Container() ],
                ),
              ],
            ),
            Column(
              children: [
                SizedBox(width: sp(40.0))
              ],
            ),
            Column(
              children: [ bigButton ?? Container() ],
            )
          ],
        ),
      ),
    );
  }

}