import 'package:appbase/appbase.dart';
import 'package:flutter/material.dart';
import 'package:sycomponents/components.dart';

class QuestionAnswerPage extends StatefulWidget {
  const QuestionAnswerPage({super.key});

  @override
  State<QuestionAnswerPage> createState() => _QuestionAnswerPageState();
}

class _QuestionAnswerPageState extends State<QuestionAnswerPage> {


  List<Widget> createQas() {

    var groups = AppServiceManager.appConfig.qas.map((dynamic qa) => [
      Align(
        /// 这个 align 非常的重要，使得较短的 title 即（Q）不会默认居中展示，而是靠左展示
        alignment: Alignment.centerLeft,
        child: Wrap(
          children: [
            Text(qa.q, style: TextStyle(fontWeight: FontWeight.bold, fontSize: sp(16.0), color: Colors.grey.shade600))
          ],
        ),
      ),
      Padding(
        padding: EdgeInsets.only(top: sp(10.0), bottom: sp(14.0)),
        child: Wrap(children: [
          Text(qa.a, style: TextStyle(fontSize: sp(16.0)))
        ],),
      )      
    ]).toList();

    List<Widget> eles = [];

    for (var g in groups) {
      eles.addAll(g);
    }

    return eles;

  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("常见问题集锦"),
      ),
      body: Padding(
        padding: EdgeInsets.all(sp(14.0)),
        child: SingleChildScrollView(
          child: Column(
            children: createQas()
          ),
        ),
      ),
    );
  }
}