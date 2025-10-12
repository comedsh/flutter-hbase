import 'package:appbase/appbase.dart';
import 'package:flutter/material.dart';
import 'package:hbase/hbase.dart';


abstract class HBaseAppConfig extends AppConfig {

  /// 抽象该方法主要是为了应对 beaut 子项目 chk、非 chk 以及非 chk 非会员、会员用户的 SalePage backgroundImage 都不同的情况
  Widget get salePageBackgroundImage;
}

class HBaseDisplay extends Display {
  final bool showJubao;
  final bool showMeHomeScore;
  final bool showPostSubmit;
  final UploadTsDisplayMode uploadTsDisplayMode;
  final List<String> chnCodes;
  /// 总分类标签
  final List<ChannelTag> tags;
  /// 热榜页面的 tags，根据现在 model，如果这个值不存在那么返回的是一个空数组
  final List<ChannelTag> hotTags; 
  final List<String>? searchHotKeywords;

  HBaseDisplay({
    required super.showCleanCache, 
    required super.showBeianNum,
    required super.showSubscrRenewalDesc,
    required this.showJubao,    
    required this.showMeHomeScore, 
    required this.showPostSubmit,
    required this.uploadTsDisplayMode,
    required this.chnCodes, 
    required this.tags, 
    required this.hotTags,
    this.searchHotKeywords
  });

  HBaseDisplay.fromJson(super.json) 
    : showJubao = json['showJubao'],
      chnCodes = json['chnCodes'].map<String>((code) => code.toString()).toList(),  // json['chnCodes'] 的类型是 List<dynamic> 因此这里必须转换一下
      tags = json['tags'].map<ChannelTag>((tag) => ChannelTag.fromJson(tag)).toList(),
      hotTags = json['hotTags'].map<ChannelTag>((tag) => ChannelTag.fromJson(tag)).toList(),
      searchHotKeywords = json['searchHotKeywords']?.map<String>((s) => s.toString()).toList(),
      showMeHomeScore = json['showMeHomeScore'],
      showPostSubmit = json['showPostSubmit'],
      uploadTsDisplayMode = UploadTsDisplayMode.values.byName(json['uploadTsDisplayMode']),
      super.fromJson();
}

enum UploadTsDisplayMode {
  datetime,
  timeAgo
}