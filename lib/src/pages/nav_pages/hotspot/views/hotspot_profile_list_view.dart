import 'package:flutter/material.dart';
import 'package:hbase/hbase.dart';

class HotspotProfileListView extends StatelessWidget {
  final List<String>? chnCodes;
  final List<String>? tagCodes;

  const HotspotProfileListView({super.key, this.chnCodes, this.tagCodes});
  
  @override
  Widget build(BuildContext context) {
    return ProfileListView(pager: HotestProfilePager(chnCodes: chnCodes, tagCodes: tagCodes));
  }
}
