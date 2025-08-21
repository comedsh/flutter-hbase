class Profile {
  final String code;
  final String name;
  final String avatar;
  final String? description;
  int followerCount;  // 粉丝数量
  final int followedCount;  // 关注数量
  final int postCount;
  
  Profile({
    required this.code, 
    required this.name, 
    required this.avatar, 
    this.description, 
    required this.followerCount,
    required this.followedCount,
    required this.postCount
  });

  Profile.fromJson(Map<String, dynamic> json)
    : code = json['code'],
      name = json['name'],
      avatar = json['avatar'],
      description = json['description'],
      followerCount = json['followerCount'],
      followedCount = json['followedCount'],
      postCount = json['postCount'];

  /// 注意 save [User] 到本地存储会用到该方法进行序列化
  Map<String, dynamic> toJson() => 
    <String, dynamic> {
      'code': code,
      'name': name,
      'avatar': avatar,
      'description': description,
      'followerCount': followerCount,
      'followedCount': followedCount,
      'postCount': postCount
    };

  /// 重载 == 方法
  /// 只需要比较 ID 即可 
  @override
  bool operator ==(Object other) =>
      other is Profile &&
      other.runtimeType == runtimeType &&
      other.code == code;

  @override
  int get hashCode => code.hashCode;    
}