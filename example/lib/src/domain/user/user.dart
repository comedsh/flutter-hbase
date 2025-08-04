import 'package:appbase/appbase.dart';

/// 有关 User 的泛化说明：
/// 
class DemoUser extends User{

  int? remainPoints = 0;
  /// 注意，[username] 和 [email] 是额外的字段信息，初次 hello 的时候服务器只会存储 base [User] 的信息；
  /// 因此第一次 hello 得到的 [username] 和 [email] 这些扩展信息是空的，因此必须允许为 nullable
  String? username;
  String? email;
  

  DemoUser({
    required super.accessToken,
    required super.createTs,  
    super.subscr,
    this.remainPoints,
    this.username, 
    this.email
  });

  /// [json] data could be loaded from remote or local storage
  /// 如何调用 super.fromJson 参考 https://stackoverflow.com/questions/62918182/how-to-create-super-and-sub-class-from-json
  DemoUser.fromJson(super.json)
    : remainPoints = json['remainPoints'],
      username = json['username'],
      email = json['email'],
      super.fromJson();

  /// 注意 save [DemoUser] 到本地存储会用到该方法进行序列化以及反序列化
  @override
  Map<String, dynamic> toJson() => 
    {...super.toJson(), 'remainPoints': remainPoints, 'username': username, 'email': email};

}