import 'package:appbase/appbase.dart';
import 'package:hbase/hbase.dart';
import 'package:sycomponents/components.dart';

enum BlurType {
  blur,
  limitPlay,
  unBlur
}

class Post {
  final String shortcode;
  final String profileCode;    
  final String? caption; // 翻译后的贴文
  final String? captionRaw; // 原始未翻译的贴文
  final String? location;
  int favorites;
  int likes;
  final double height;
  final double width;  
  final String thumbnail;
  final PostType type;
  final DateTime uploadTs;
  final bool? isPinned;
  bool isLiked;
  bool isFavorited;
  final List<PostSlot> slots;
  final BlurType blurType;
  final BlurDepth? blurDepth;
  final int? limitPlayMilliseconds;
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
    this.isPinned, 
    required this.isLiked, 
    required this.isFavorited,
    required this.slots,
    required this.blurType,
    this.blurDepth,
    this.limitPlayMilliseconds,
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
      isLiked = json['isLiked'],
      isFavorited = json['isFavorited'],
      slots = json['slots'].map<PostSlot>((s) => PostSlot.fromJson(s)).toList(),
      blurType = BlurType.values.byName(json['blurType']),
      blurDepth = json['blurDepth'] != null ? BlurDepth.values.byName(json['blurDepth']) : null,
      limitPlayMilliseconds = json['limitPlayMilliseconds'],
      profile = Profile.fromJson(json['profile']);

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
      'uploadTs': uploadTs.toIso8601String(),
      'isPinned': isPinned,
      'isLiked': isLiked,
      'isFavorited': isFavorited,
      'blur': blurType.name,
      'blurDepth': blurDepth?.name
    };  

  /// 重载 == 方法
  /// 只需要比较 ID 即可 
  @override
  bool operator ==(Object other) =>
      other is Post &&
      other.runtimeType == runtimeType &&
      other.shortcode == shortcode;

  @override
  int get hashCode => shortcode.hashCode;

  String get typeName => PostHelper.getTypeName(type);
}
