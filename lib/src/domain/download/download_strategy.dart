class DownloadStrategy {
  final PayToDownload? payToDownload;
  final PointToDownload? pointToDownload;
  final QuotaToDownload? quotaToDownload;
  final bool unlimitToDownload;  
  final String? purchasePointDesc;
  final String? purchaseSubscrDesc;
  final String? scoreToDownload;

  DownloadStrategy({
    this.payToDownload, 
    this.pointToDownload, 
    this.quotaToDownload, 
    this.unlimitToDownload = false, 
    this.purchasePointDesc, 
    this.purchaseSubscrDesc, 
    this.scoreToDownload
  });

  DownloadStrategy.fromJson(Map<String, dynamic> json) 
    : payToDownload = json['payToDownload'] != null ? PayToDownload.fromJson(json['payToDownload']) : null,
      pointToDownload = json['pointToDownload'] != null ? PointToDownload.fromJson(json['pointToDownload']) : null,
      quotaToDownload = json['quotaToDownload'] != null ? QuotaToDownload.fromJson(json['quotaToDownload']) : null,
      unlimitToDownload = json['unlimitToDownload'] ?? false,
      purchasePointDesc = json['purchasePointDesc'],
      purchaseSubscrDesc = json['purchaseSubscrDesc'],
      scoreToDownload = json['scoreToDownload'];
}

class PayToDownload {
  final String iapProductId;
  PayToDownload({required this.iapProductId});
  PayToDownload.fromJson(Map<String, dynamic> json)
    : iapProductId = json['iapProductId'];
}

class PointToDownload {
  final int remainPoints;
  final int pointToSpent;
  PointToDownload({required this.remainPoints, required this.pointToSpent});
  PointToDownload.fromJson(Map<String, dynamic> json)
    : remainPoints = json['remainPoints'],
      pointToSpent = json['pointToSpent'];
}

/// 是指购买了配额会员，即每天可以享有的下载配额的情况
class QuotaToDownload {
  final int quota;
  QuotaToDownload({required this.quota});
  QuotaToDownload.fromJson(Map<String, dynamic> json)
    : quota = json['quota'];
}

