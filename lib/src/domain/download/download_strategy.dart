import 'package:appbase/appbase.dart';

class DownloadStrategy {
  final PayToDownload? payToDownload;
  final PointToDownload? pointToDownload;
  final QuotaToDownload? quotaToDownload;
  final bool unlimitToDownload;  
  final String? purchasePointDesc;
  final String? purchaseSubscrDesc;
  final ScoreToDownload? scoreToDownload;
  final String? failNotification;

  DownloadStrategy({
    this.payToDownload, 
    this.pointToDownload, 
    this.quotaToDownload, 
    this.unlimitToDownload = false, 
    this.purchasePointDesc, 
    this.purchaseSubscrDesc, 
    this.scoreToDownload,
    this.failNotification
  });

  DownloadStrategy.fromJson(Map<String, dynamic> json) 
    : payToDownload = json['payToDownload'] != null ? PayToDownload.fromJson(json['payToDownload']) : null,
      pointToDownload = json['pointToDownload'] != null ? PointToDownload.fromJson(json['pointToDownload']) : null,
      quotaToDownload = json['quotaToDownload'] != null ? QuotaToDownload.fromJson(json['quotaToDownload']) : null,
      unlimitToDownload = json['unlimitToDownload'] ?? false,
      purchasePointDesc = json['purchasePointDesc'],
      purchaseSubscrDesc = json['purchaseSubscrDesc'],
      scoreToDownload = json['scoreToDownload'] != null ? ScoreToDownload.fromJson(json['scoreToDownload']) : null,
      failNotification = json['failNotification'];
}

class PayToDownload {
  final String iapProductId;
  PayToDownload({required this.iapProductId});
  PayToDownload.fromJson(Map<String, dynamic> json)
    : iapProductId = json['iapProductId'];
}

class PointToDownload {
  final int pointToSpend;
  PointToDownload({required this.pointToSpend});
  PointToDownload.fromJson(Map<String, dynamic> json)
    : pointToSpend = json['pointToSpend'];
}

/// 是指购买了配额会员，即每天可以享有的下载配额的情况
class QuotaToDownload {
  final int quotaRemains;
  final PostType? postType;
  QuotaToDownload({required this.quotaRemains, this.postType});
  QuotaToDownload.fromJson(Map<String, dynamic> json)
    : quotaRemains = json['quotaRemains'],
      postType = json['postType'] != null ? PostType.values.byName(json['postType']) : null;
}

class ScoreToDownload {
  final String title;
  final String content;
  final String btnText;
  ScoreToDownload({required this.title, required this.content, required this.btnText});
  ScoreToDownload.fromJson(Map<String, dynamic> json)
    : title = json['title'],
      content = json['content'],
      btnText = json['btnText'];
}
