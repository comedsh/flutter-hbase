class Channel {
  final String name;
  final String code;

  Channel({required this.name, required this.code});  

  Channel.fromJson(Map<String, dynamic> json)
    : code = json['code'],
      name = json['name'];

  Map<String, dynamic> toJson() => 
    <String, dynamic> {
      'code': code,
      'name': name
    };    

  /// 重载 == 方法
  /// 只需要比较 ID 即可 
  @override
  bool operator ==(Object other) =>
      other is Channel &&
      other.runtimeType == runtimeType &&
      other.code == code;

  @override
  int get hashCode => code.hashCode;    

}