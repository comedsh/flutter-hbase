class Profile {
  final String code;
  final String name;
  final String avatar;
  final String? description;
  final int follwerCount;

  Profile({
    required this.code, 
    required this.name, 
    required this.avatar, 
    this.description, 
    required this.follwerCount
  });

  Profile.fromJson(Map<String, dynamic> json)
    : code = json['code'],
      name = json['name'],
      avatar = json['avatar'],
      description = json['description'],
      follwerCount = json['follwerCount'];

  /// 注意 save [User] 到本地存储会用到该方法进行序列化
  Map<String, dynamic> toJson() => 
    <String, dynamic> {
      'code': code,
      'name': name,
      'avatar': avatar,
      'description': description,
      'follwerCount': follwerCount
    };  
}