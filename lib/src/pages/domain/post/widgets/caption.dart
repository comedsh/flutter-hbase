import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hbase/hbase.dart';
import 'package:sycomponents/components.dart';

class Caption extends StatefulWidget {
  final Post post;
  final int maxLines;
  final bool isAllowedTrans;
  final Function? unlockTransCallback;
  /// 在“点击翻译”的右侧添加一个 tailer Widget 目的是用来添加 post 的发布时间
  final Widget? tailer;
  /// 默认展示原文，点击翻译按钮后可展示翻译内容
  const Caption({
    super.key, 
    required this.post, 
    required this.maxLines, 
    required this.isAllowedTrans,
    this.unlockTransCallback,
    this.tailer
  });

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
          maxWidth: Screen.widthWithoutContext() * 0.7,
          style: TextStyle(fontSize: sp(14), color: Colors.white)
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children:[
            // 一个小优化，只有有内容的前提下才会显示翻译按钮
            if (widget.post.captionRaw != null) 
              GestureDetector(
                onTap: () {
                  if (widget.isAllowedTrans) {
                    isTranslated.value = !isTranslated.value;
                  } else {
                    assert(widget.unlockTransCallback != null, 'unlockTransCallback param can not be null if isAllowedTrans is false');
                    widget.unlockTransCallback!();
                  }
                }, // toggle
                child: Padding(
                  padding: EdgeInsets.only(top: sp(8.0), right: sp(8.0)),
                  child: !isTranslated.value
                    ? Text('点击翻译', style: TextStyle(fontSize: sp(14), color: Colors.white))
                    : Text('查看原文', style: TextStyle(fontSize: sp(14), color: Colors.white))
                ),
              )
            , 
            if(widget.tailer != null) 
              Padding(
                padding: EdgeInsets.only(top: sp(8.0)),
                child: widget.tailer!,
              )
          ]
        )
      ],
    ));
  }
}