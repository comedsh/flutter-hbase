// ignore_for_file: depend_on_referenced_packages
import 'package:flutter/material.dart';
import 'package:sycomponents/components.dart';

class MyspacePage extends StatefulWidget {
  const MyspacePage({super.key});

  @override
  State<MyspacePage> createState() => _MyspacePageState();
}

class _MyspacePageState extends State<MyspacePage> {

  @override
  Widget build(BuildContext context) {

    return Container(
      padding: EdgeInsets.symmetric(horizontal: sp(12.0)),
      width: Screen.width(context),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            Colors.red.shade50,
            Colors.red.shade100,
            Colors.red.shade300,
            Colors.red.shade500
          ]
        ),
      ),
      child: Column(
        children: [
          
        ]
      )
    );
  }
}