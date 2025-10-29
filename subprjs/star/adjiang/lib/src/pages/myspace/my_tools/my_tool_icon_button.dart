// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:sycomponents/components.dart';

class MyToolIconButton extends StatelessWidget {
  final IconData iconData;
  final String text;
  final Function onTapCallback;
  final bool isDark;
  final Color? iconLightModeColor;
  final double? iconSize;
  final double? fontSize;
  const MyToolIconButton({super.key, required this.iconData, required this.text, required this.onTapCallback, required this.isDark, this.iconLightModeColor, this.iconSize, this.fontSize, });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTapCallback(),
      child: Column(
        children: [
          Icon(iconData, size: iconSize ?? sp(28), color: !isDark ? iconLightModeColor : Colors.white),
          SizedBox(height: sp(4)),
          Text(text, style: TextStyle(fontSize: fontSize ?? sp(14)))
        ]
      ),
    );
  }
}