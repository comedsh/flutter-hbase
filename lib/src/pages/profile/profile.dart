import 'package:flutter/material.dart';
import 'package:hbase/hbase.dart';

class ProfilePage extends StatelessWidget {
  final Profile profile;
  const ProfilePage({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(profile.name)
      ),
      body: Container()
    );
  }
}