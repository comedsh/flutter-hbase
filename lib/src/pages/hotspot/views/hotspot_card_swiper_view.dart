import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hbase/hbase.dart';
import 'package:sycomponents/components.dart';

/// 一个卡片对应一个 tagCode
class HotspotCardSwiperView extends StatefulWidget {
  final List<String> chnCodes;
  final List<String> tagCodes;
  final List<Profile> profiles;
  
  const HotspotCardSwiperView({super.key, required this.profiles});

  @override
  State<HotspotCardSwiperView> createState() => _HotspotCardSwiperViewState();
}

class _HotspotCardSwiperViewState extends State<HotspotCardSwiperView> {
  final loading = true.obs;


  @override
  Widget build(BuildContext context) {
    /// viewportFraction 是指该 page 最多能够占用的屏幕的宽度
    final controller = PageController(viewportFraction: 0.8, keepPage: true);

    final pages = List.generate(
      6, 
      (index) => Card(
        elevation: 5, // Controls the shadow size
        margin: EdgeInsets.symmetric(horizontal: sp(14), vertical: sp(4)), // Adds margin around the card
        // margin: EdgeInsets.only(left: sp(16), right: sp(8.0), top: sp(4), bottom: sp(4)),
        child: Padding(
          padding: EdgeInsets.all(sp(16.0)),
          child: Column(
            mainAxisSize: MainAxisSize.min, // Make column take minimum height
            children: <Widget>[
              // title row
              Row(
                children: [
                  Text(
                    '欧美',
                    style: TextStyle(fontSize: sp(20), fontWeight: FontWeight.bold),
                  ),
                  // 封装一个 Row 的目的是为了使用 MainAxisAlignment.end 让按钮能够右对齐
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {  },
                          child: const Text('查看更多'),
                        ),
                      ],
                    ),
                  )
                ],
              ),
              const SizedBox(height: 10),



              const Text('You can place various widgets here.'),
              Row(
                children: [
                  // ProfileAvatar(profile: profile, size: size)
                ],
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  // Handle button press
                },
                child: const Text('Learn More'),
              ),
            ],
          ),
        ),
      )
    );

    return SizedBox(
      height: sp(460),
      child: PageView.builder(
        padEnds: false, // 关键，不用在两侧添加 padding
        controller: controller,
        itemCount: pages.length,
        itemBuilder: (_, index) {
          return pages[index];
        },
      ),
    );

    
  }
}