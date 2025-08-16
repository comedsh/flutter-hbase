/// [ChannelTag] 这个名字其实蛮有争议的哦，它其实并不隶属于 channel 而是 Profile 的一个属性而已；
/// 但是历史造就了这样一个名字，因此延用这个定义吧！
class ChannelTag {  
  final String name;
  final String code;

  ChannelTag({required this.name, required this.code});

  ChannelTag.fromJson(Map<String, dynamic> json)
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
      other is ChannelTag &&
      other.runtimeType == runtimeType &&
      other.code == code;

  @override
  int get hashCode => code.hashCode;      
}