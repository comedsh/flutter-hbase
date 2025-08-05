import 'package:hbase/hbase.dart';

enum PostType {
  photo,
  album,
  video,
  reel
}

class Post {
  final String shortcode;
  final String profileCode;    
  final String? caption; // 翻译后的贴文
  final String? captionRaw; // 原始未翻译的贴文
  final String? location;
  final int favorites;
  final int likes;
  final double height;
  final double width;  
  final String thumbnail;
  final PostType type;
  final DateTime uploadTs;
  final bool isPinned;
  final List<PostSlot> slots;
  final Profile profile;

  Post({
    required this.shortcode, 
    required this.profileCode, 
    this.caption, 
    this.captionRaw, 
    this.location, 
    required this.favorites, 
    required this.likes, 
    required this.height, 
    required this.width, 
    required this.thumbnail, 
    required this.type, 
    required this.uploadTs, 
    required this.isPinned, 
    required this.slots,
    required this.profile
  });
  
  Post.fromJson(Map<String, dynamic> json)
    : shortcode = json['shortcode'],
      profileCode = json['profileCode'],
      caption = json['caption'],
      captionRaw = json['captionRaw'],
      location = json['location'],
      favorites = json['favorites'],
      likes = json['likes'],
      height = json['height'].toDouble(),
      width = json['width'].toDouble(),
      thumbnail = json['thumbnail'],
      type = PostType.values.byName(json['type']),
      uploadTs = DateTime.parse(json['uploadTs']),
      isPinned = json['isPinned'],
      slots = json['slots'].map<PostSlot>((s) => PostSlot.fromJson(s)).toList(),
      profile = Profile.fromJson(json['profile']);

  /// 注意 save [User] 到本地存储会用到该方法进行序列化
  Map<String, dynamic> toJson() => 
    <String, dynamic> {
      'shortcode': shortcode,
      'profileCode': profileCode,
      'caption': caption,
      'captionRaw': captionRaw,
      'location': location,
      'favorites': favorites,
      'likes': likes,
      'height': height,
      'width': width,
      'thumbnail': thumbnail,
      'type': type.name,
      'uploadTs': uploadTs.toIso8601String()
    };  


}

class PostSlot {
  final String pic;
  final String? video;

  PostSlot({
    required this.pic, this.video
  });

  PostSlot.fromJson(Map<String, dynamic> json)
    : pic = json['pic'],
      video = json['video'];

  Map<String, dynamic> toJson() =>
    <String, dynamic> {
      'pic': pic,
      'video': video
    };
} 