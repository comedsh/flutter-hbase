import 'package:flutter/material.dart';
import 'package:hbase/hbase.dart';

class BlockProfileNotification extends Notification {
  final Profile profile;
  BlockProfileNotification(this.profile);
}