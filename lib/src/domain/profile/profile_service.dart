

import 'dart:convert';

import 'package:hbase/hbase.dart';
import 'package:shared_preferences/shared_preferences.dart';


// ignore: constant_identifier_names
const BLOCK_PROFILE_EVENT = 'blockProfileEvent';



/// 拉黑博主
class BlockProfileService {

  // ignore: constant_identifier_names
  static const BLOCKED_PROFILES = 'blocked_profiles';

  /// add the [profile] into the block list
  static block(Profile profile) async {
    var profiles = await getAllBlockedProfiles();
    if (!profiles.contains(profile)) {
      profiles.add(profile);
      await _serialize(profiles);
    }
  }

  /// remove the [profile] from the block list
  static remove(Profile profile) async {
    var profiles = await getAllBlockedProfiles();
    profiles.removeWhere((p) => p.code == profile.code);
    await _serialize(profiles);
  }

  static Future<List<Profile>> getAllBlockedProfiles() async {
    var pref = await SharedPreferences.getInstance();
    List<String>? vals = pref.getStringList(BLOCKED_PROFILES);
    return vals == null 
      ? []
      : vals.map((val) => Profile.fromJson(jsonDecode(val))).toList();
  }

  static Future<bool> hasBlockedProfile() async {
    var blockedProfiles = await getAllBlockedProfiles();
    return blockedProfiles.isNotEmpty;
  }

  static _serialize(List<Profile> profiles) async {
    var pref = await SharedPreferences.getInstance();
    var vals = profiles.map((p) => jsonEncode(p.toJson())).toList();
    pref.setStringList(BLOCKED_PROFILES, vals);
  }

}