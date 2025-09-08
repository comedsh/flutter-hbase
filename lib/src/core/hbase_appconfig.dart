import 'package:appbase/appbase.dart';

class HBaseDisplay extends Display {
  final bool showJubao;
  final bool showMeHomeScore;
  final bool enableScoreSimple;
  final bool enableScoreTarget;
  final bool enableScoreDownload;

  HBaseDisplay({
    required super.showCleanCache, 
    required super.showBeianNum,
    required super.showSubscrRenewalDesc,
    required this.showJubao,    
    required this.showMeHomeScore, 
    required this.enableScoreSimple, 
    required this.enableScoreTarget, 
    required this.enableScoreDownload
  });

  HBaseDisplay.fromJson(super.json) 
    : showJubao = json['showJubao'],
      showMeHomeScore = json['showMeHomeScore'],
      enableScoreSimple = json['enableScoreSimple'],
      enableScoreTarget = json['enableScoreTarget'],
      enableScoreDownload = json['enableScoreDownload'],
      super.fromJson();
}