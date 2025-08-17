import 'package:flutter/material.dart';
import 'package:hbase/hbase.dart';

class HotspotProfileListViewPage extends StatelessWidget {
  final List<String>? chnCodes;
  final List<String>? tagCodes;
  final String? title;
  const HotspotProfileListViewPage({super.key, this.chnCodes, this.tagCodes, this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: title != null ? Text(title!) : null),
      body: HotspotProfileListView(
        chnCodes: chnCodes,
        tagCodes: tagCodes,
      )
    );
  }
}