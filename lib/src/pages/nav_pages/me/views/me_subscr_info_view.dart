import 'package:appbase/appbase.dart';
import 'package:flutter/material.dart';
import 'package:flutter_font_icons/flutter_font_icons.dart';
import 'package:get/get.dart';
import 'package:hbase/hbase.dart';
import 'package:sycomponents/components.dart';

/// 整个展示逻辑在 Notability 的 MeSubscrInfoView 的设计手稿中已经详细的阐述；归纳起来就是后台所开放的购买权限
/// 和用户已有的权利结合起来进行展示；为了能够让实现逻辑变得简单和可控，我将 [MeSubscrInfoView] 独立分割为了多个
/// 小的组件，分别是 leading, title, subTitle 和 bigBotton，其中 subTitle 负责展示会员规则和积分概要；
class MeSubscrInfoView extends StatefulWidget {
  const MeSubscrInfoView({super.key});

  @override
  State<MeSubscrInfoView> createState() => _MeSubscrInfoViewState();
}

class _MeSubscrInfoViewState extends State<MeSubscrInfoView> {

  @override
  Widget build(BuildContext context) {
    return Obx(() => Card(
      child: ListTile(
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
    ));
  }

  /// 展示皇冠的情况有两种
  /// 1. 非会员或过期会员且后台开启了 unlockSubscr，其实就是表示可以购买会员，因此显示皇冠
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
          // color: AppServiceManager.appConfig.appTheme.seedColor,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!user.hasPurchasedSubscr() && user.isUnlockSubscrSale) 
          Text('解锁会员权限 >', style: TextStyle(color: Colors.amber[200])),
        if (user.hasPurchasedSubscr()) ...subscrDescs(user),
        if (user.point?.hasPurchasedPoint == true) ...pointDescs(user)
      ],
    );
  }

  List<Widget> subscrDescs(HBaseUser user) {
    return [
      SizedBox(height: sp(4)),
      Row(
        children: [
          const Text('会员有效期', style: TextStyle(color: Colors.white30)),
          if (user.subscr?.isValid == false) ... [
            SizedBox(width: sp(4)),
            const Text('(已过期)', style: TextStyle(color: Colors.deepOrange))
          ]
        ],
      ),
      Wrap(children: [
        // Text('从 ${HBaseUtils.dateFormatterHhmm.format(user.subscr!.start.toLocal())} 开始至 ${HBaseUtils.dateFormatterHhmm.format(user.subscr!.end.toLocal())} 结束'),
        /// 备注，start 和 end 都是 utc date，因此直接使用 toLocal 既可以转换成本地时间进行展示
        Text('${HBaseUtils.dateFormatterHhmm.format(user.subscr!.start.toLocal())} - ${HBaseUtils.dateFormatterHhmm.format(user.subscr!.end.toLocal())}'),
      ],),
      /// 只有当用户处于有效订阅的情况下才展示条款，因为条款可能会发生变化，过期后的会员发现会员期间没有享受到变化的内容，可能会投诉；
      if (user.subscr?.isValid == true) 
        ... [
          const Divider(thickness: 0.5, color: Colors.white24),
          const Text('会员权益', style: TextStyle(color: Colors.white30)),
          BulletList(
            items: user.subscr!.ruleDescs,
            bulletSize: sp(12), 
            bulletPaddingLeft: sp(4), 
            textPaddingLeft: sp(6),
            rowPaddingBottom: 0
          ),
        ]
    ];
  }

  List<Widget> pointDescs(HBaseUser user) {
    return [
      const Divider(thickness: 0.5, color: Colors.white24),
      const Text('积分概要', style: TextStyle(color: Colors.white30)),
      BulletList(
        items: ['积分余额 ${user.point?.remainPoints}'],
        bulletSize: sp(12), 
        bulletPaddingLeft: sp(4), 
        textPaddingLeft: sp(6),
        rowPaddingBottom: 0
      )      
      // 有点画蛇添足了，没有必要再加一个点击进入购买积分的链接
      // Row(
      //   children: [
      //     Text('积分余额 ${user.point?.remainPoints}'),
      //     if (user.isUnlockPointSale) ... [
      //       SizedBox(width: sp(6)), 
      //       GestureDetector(
      //         onTap: () => Get.to(() => 
      //           SalePage(
      //             saleGroups: AppServiceManager.appConfig.saleGroups, 
      //             initialSaleGroupId: SaleGroupIdEnum.points
      //           )
      //         ),
      //         child: const Text('购买积分', style: TextStyle(color: Color.fromARGB(255, 14, 158, 230)))
      //       )
      //     ]
      //   ],
      // )
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
    if (user.isUnlockSubscrSale || user.isUnlockAdvancedSubscrSale || user.isUnlockNonRenewingSubscrSale) {
      var text = '';
      if (user.isUnlockSubscrSale || user.isUnlockNonRenewingSubscrSale) {
        text = '立即开通';
      }
      else {
        text = '升级订阅';
      }
      return __bigButton(
        text: text, 
        width: sp(144.0), 
        fontSize: sp(16.0), 
        clickCallback: () => Get.to(() => SalePage(
          saleGroups: AppServiceManager.appConfig.saleGroups,
          backgroundImage: (AppServiceManager.appConfig as HBaseAppConfig).salePageBackgroundImage,
        ))
      );
    }
    /// 如果不能展示会员的，那么展示积分
    else if (user.isUnlockPointSale) {
      return __bigButton(
        text: '购买积分', 
        width: sp(144.0), 
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