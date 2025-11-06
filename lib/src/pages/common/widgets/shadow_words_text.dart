import 'package:flutter/material.dart';

import 'shadow.dart';

class ShadowedWordsText extends StatelessWidget {
  final String text;
  final TextStyle baseStyle;
  final Shadow? wordShadow;
  final int? maxLines;
  final TextOverflow? overflow;

  /// 将 [text] 文字进行拆分，然后一个一个的拼接 shadow
  const ShadowedWordsText({
    super.key,
    required this.text,
    required this.baseStyle,
    this.wordShadow, 
    this.maxLines, 
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    List<String> words = text.split(' ');
    List<TextSpan> textSpans = [];

    for (String word in words) {
      textSpans.add(
        TextSpan(
          text: '$word ', // Add a space after each word for proper spacing
          style: baseStyle.copyWith(
            shadows: [wordShadow ?? TextShadow.defaultShadow],
          ),
        ),
      );
    }

    return RichText(
      overflow: overflow ?? TextOverflow.clip,
      maxLines: maxLines,
      text: TextSpan(
        children: textSpans,
      ),
    );
  }

}
