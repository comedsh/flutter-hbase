import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class PostService {

}


// 帖子屏蔽功能服务
class PostUnseenService {
  // ignore: constant_identifier_names
  static const UNSEEN_POSTS = "unseen_posts";


  static saveUnseenPost(String shortcode) async {
    var pref = await SharedPreferences.getInstance();    
    var unseenPosts = await loadUnseenPosts();
    if (!unseenPosts.contains(shortcode)) {
      unseenPosts.add(shortcode);
      pref.setString(UNSEEN_POSTS, jsonEncode(unseenPosts));
    }
  }

  static Future<List<String>> loadUnseenPosts() async{
    var pref = await SharedPreferences.getInstance();              
    String? val = pref.getString(UNSEEN_POSTS);
    return val == null 
      ? []
      // 注意 jsonDecode(val) 得到的是 List<dynamic> 因此需要转换成 List<String> 
      : jsonDecode(val).map<String>((v) => v.toString()).toList();
  }

}