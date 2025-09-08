import 'package:appbase/appbase.dart';
import 'package:hbase/hbase.dart';

class HBaseDisplay extends Display {
  final bool showJubao;
  final bool showMeHomeScore;
  final bool enableScoreSimple;
  final bool enableScoreTarget;
  final bool enableScoreDownload;
  final List<String> chnCodes;
  /// 总分类标签
  final List<ChannelTag> tags;
  /// 热榜页面的 tags
  final List<ChannelTag> hotTags; 

  HBaseDisplay({
    required super.showCleanCache, 
    required super.showBeianNum,
    required super.showSubscrRenewalDesc,
    required this.showJubao,    
    required this.showMeHomeScore, 
    required this.enableScoreSimple, 
    required this.enableScoreTarget, 
    required this.enableScoreDownload,
    required this.chnCodes, 
    required this.tags, 
    required this.hotTags,
  });

  HBaseDisplay.fromJson(super.json) 
    : showJubao = json['showJubao'],
      chnCodes = json['chnCodes'].map<String>((code) => code.toString()).toList(),  // json['chnCodes'] 的类型是 List<dynamic> 因此这里必须转换一下
      tags = json['tags'].map<ChannelTag>((tag) => ChannelTag.fromJson(tag)).toList(),
      hotTags = json['hotTags'].map<ChannelTag>((tag) => ChannelTag.fromJson(tag)).toList(),
      showMeHomeScore = json['showMeHomeScore'],
      enableScoreSimple = json['enableScoreSimple'],
      enableScoreTarget = json['enableScoreTarget'],
      enableScoreDownload = json['enableScoreDownload'],
      super.fromJson();
}