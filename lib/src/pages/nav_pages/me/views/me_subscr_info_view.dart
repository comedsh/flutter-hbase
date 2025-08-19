import 'package:appbase/appbase.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
      // margin: const EdgeInsets.all(0.0),  // 消除默认两边的 margin
      child: _unSubscribedContent()
    );
  }

  Widget _unSubscribedContent() {
    return Padding(
      padding: EdgeInsets.only(top: sp(16.0), bottom: sp(16.0)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(
            children: [
              Icon(
                IconFont.icon_sy_huangguan, 
                color: const Color.fromARGB(255, 252, 189, 1),
                size: sp(48.0),
              )
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text('VIP', style: TextStyle(color: Colors.amber[200], fontSize: sp(18), fontWeight: FontWeight.bold),),
                ],
              ),
              Row(
                children: [
                  Text('解锁会员权限 >', style: TextStyle(color: Colors.amber[200]),),
                ],
              ),
            ],
          ),
          Column(
            children: [
              SizedBox(width: sp(40.0))
            ],
          ),
          Column(
            children: [
              __subscrButton(
                text: '立即开通', 
                width: sp(144.0), 
                fontSize: sp(16.0), 
                clickCallback: () => Get.to(() => SalePage(saleGroups: AppServiceManager.appConfig.saleGroups,))
              )
            ],
          )
        ],
      ),
    );
  }

  Widget __subscrButton({
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


}