// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:sycomponents/components.dart';

import '../constants.dart';

class SubscribeInfoView extends StatefulWidget {
  const SubscribeInfoView({super.key});

  @override
  State<SubscribeInfoView> createState() => _SubscribeInfoViewState();
}

class _SubscribeInfoViewState extends State<SubscribeInfoView> {
  
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
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: <Color>[
                  Colors.amber.shade900,
                  Colors.amber.shade800,
                  Colors.amber.shade700,
                  Colors.amber.shade500,
                  Colors.amber.shade200,
                ]
              ),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: MyspacePageConstants.cardPaddingSize),
              child: Row(
                children: [
                  Text('VIP 会员', style: TextStyle(fontSize: sp(16), fontWeight: FontWeight.w600, color: Colors.white)),
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