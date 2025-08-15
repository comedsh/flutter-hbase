import 'package:flutter/material.dart';
import 'package:hbase/hbase.dart';

class HotspotPage extends StatelessWidget {
  const HotspotPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('热榜'),),
      body: const HotspotCardSwiperView(profiles: [])
    );
  }
}