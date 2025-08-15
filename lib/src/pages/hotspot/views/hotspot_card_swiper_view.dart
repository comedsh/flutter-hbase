import 'package:flutter/material.dart';
import 'package:hbase/hbase.dart';
import 'package:sycomponents/components.dart';

class HotspotCardSwiperView extends StatelessWidget {
  final List<Profile> profiles;
  
  const HotspotCardSwiperView({super.key, required this.profiles});

  @override
  Widget build(BuildContext context) {
    final controller = PageController(viewportFraction: 0.8, keepPage: true);
    final pages_ = List.generate(
      6,
      (index) => Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.grey.shade300,
        ),
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: SizedBox(
          height: 280,
          child: Center(
            child: Text(
              "Page $index",
              style: const TextStyle(color: Colors.indigo),
          )),
        ),
      ));

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