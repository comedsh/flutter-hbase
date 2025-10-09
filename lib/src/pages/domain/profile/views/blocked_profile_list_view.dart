import 'dart:async';

import 'package:appbase/appbase.dart';
import 'package:flutter/material.dart';
import 'package:hbase/hbase.dart';
import 'package:sycomponents/components.dart';

class BlockedProfileListView extends StatefulWidget {

  /// 最简化的 blocked profile 列表，注意无分页，因为直接从本地存储中拉取数据
  const BlockedProfileListView({super.key});

  @override
  State<BlockedProfileListView> createState() => _BlockedProfileListViewState();
}

class _BlockedProfileListViewState extends State<BlockedProfileListView> {
  late List<Profile> blockedProfiles;
  bool loading = true;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      blockedProfiles = await BlockProfileService.getAllBlockedProfiles();
      setState(() => loading = false);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return loading 
    ? const Center(child: CircularProgressIndicator())
    : blockedProfiles.isEmpty 
      ? const Center(child: Text('没有数据'))
      : ListView(
          children: blockedProfiles.map((profile) =>
            Padding(
              padding: EdgeInsets.symmetric(vertical: sp(7), horizontal: sp(22)),
              child: Row(
                children: [
                  /// 头像
                  ProfileAvatar(profile: profile, size: sp(66)),
                  SizedBox(width: sp(8)),
                  /// 名字和描述
                  SizedBox(
                    width: Screen.width(context) * 0.53,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(profile.name, style: TextStyle(fontWeight: FontWeight.w500, fontSize: sp(16))),
                        Text(
                          profile.description ?? "",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: sp(13))
                        )
                      ],
                    ),
                  ),
                  SizedBox(width: sp(8.0)),
                  /// remove button
                  GradientElevatedButton(
                    gradient: LinearGradient(colors: [
                      AppServiceManager.appConfig.appTheme.fillGradientEndColor,
                      AppServiceManager.appConfig.appTheme.fillGradientEndColor
                    ]),
                    width: sp(80),
                    height: sp(32.0),
                    borderRadius: BorderRadius.circular(13.0),
                    onPressed: () async {
                      var isConfirmed = await showConfirmDialogWithoutContext(content: '确定移除？', confirmBtnTxt: '确定', cancelBtnTxt: '不了');
                      if (isConfirmed) {
                        GlobalLoading.show('移除中，请稍后...');
                        Timer(Duration(milliseconds: Random.randomInt(800, 2800)), () async {
                          await BlockProfileService.remove(profile);
                          blockedProfiles = await BlockProfileService.getAllBlockedProfiles();
                          setState((){});
                          GlobalLoading.close();
                        });
                        

                      }
                    },
                    dense: true,
                    child: Text('移除', style: TextStyle(color: Colors.white, fontSize: sp(14), fontWeight: FontWeight.bold))
                  ),                  

                ],
              ),
            )
          ).toList()
        );
  }
}