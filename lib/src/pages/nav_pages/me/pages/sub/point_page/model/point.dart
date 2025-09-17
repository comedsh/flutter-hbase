class PointReceipt {
  final int points;
  /// 购买日期
  final DateTime createTs;
  /// 来源描述
  final String receiveDesc;

  PointReceipt({required this.points, required this.createTs, required this.receiveDesc});

  PointReceipt.fromJson(Map<String, dynamic> json)
    : points = json['points'],
      createTs = DateTime.parse(json['createTs']),
      receiveDesc = json['receiveDesc'];
}

class PointConsumption {
  final int points;
  final DateTime createTs;
  final String spentDesc;

  PointConsumption({required this.points, required this.createTs, required this.spentDesc});

  PointConsumption.fromJson(Map<String, dynamic> json)
    : points = json['points'],
      createTs = DateTime.parse(json['createTs']),
      spentDesc = json['spentDesc'];
}