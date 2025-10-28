// ignore_for_file: depend_on_referenced_packages

import 'package:adjiang/src/pages/myspace/constants.dart';
import 'package:flutter/material.dart';
import 'package:sycomponents/components.dart';

class PointInfoView extends StatefulWidget {
  const PointInfoView({super.key});

  @override
  State<PointInfoView> createState() => _PointInfoViewState();
}

class _PointInfoViewState extends State<PointInfoView> {
  
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0, // Controls the shadow size
      clipBehavior: Clip.hardEdge,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(MyspacePageConstants.cardBorderRadius), // Adjust radius as needed
      ),
      child: Column(
        children: [
          Container(
            height: sp(36),
            color: Colors.grey.shade600,
            // decoration: BoxDecoration(
            //   gradient: LinearGradient(
            //     begin: Alignment.centerLeft,
            //     end: Alignment.centerRight,
            //     colors: <Color>[
            //       Colors.grey.shade500,
            //       Colors.grey.shade400,
            //       Colors.grey.shade300,
            //       Colors.grey.shade200
            //     ]
            //   ),
            // ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: MyspacePageConstants.cardPaddingSize),
              child: Row(
                children: [
                  Text('积分概要', style: TextStyle(fontSize: sp(16), fontWeight: FontWeight.w600, color: Colors.white)),
                ],
              ),
            ),
          ),
          Center(child: Text('hello world')),
        ],
      ),
    );
  }
}