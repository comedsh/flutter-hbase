import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hbase/hbase.dart';
import 'package:sycomponents/components.dart';

class Caption extends StatefulWidget {
  final Post post;
  final int maxLines;
  const Caption({super.key, required this.post, required this.maxLines});

  @override
  State<Caption> createState() => _CaptionState();
}

class _CaptionState extends State<Caption> {

  var isTranslated = false.obs;

  @override
  Widget build(BuildContext context) {
    return Obx(() => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ExpandableText(
          minLines: 1, 
          maxLines: widget.maxLines, 
          text: !isTranslated.value 
            ? widget.post.captionRaw ?? ""
            : widget.post.caption ?? "", 
          maxWidth: Screen.widthWithoutContext() * 0.7
        ),
        // 一个小优化，只有有内容的前提下才会显示翻译按钮
        widget.post.captionRaw != null
        ? GestureDetector(
            onTap: () => isTranslated.value = !isTranslated.value, // toggle
            child: Padding(
              padding: const EdgeInsets.only(top: 6.0),
              child: !isTranslated.value
                ? const Text('点击翻译')
                : const Text('查看原文')
            ),
          )
        : Container()  
      ],
    ));
  }
}