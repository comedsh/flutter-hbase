import 'package:flutter/material.dart';

class PostPageChangedNotification extends Notification {
  final int index;
  PostPageChangedNotification(this.index);
}