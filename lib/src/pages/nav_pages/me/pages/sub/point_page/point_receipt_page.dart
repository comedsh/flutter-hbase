import 'package:flutter/material.dart';
import 'package:hbase/hbase.dart';
import 'package:sycomponents/components.dart';

class DataTableDemo extends StatefulWidget {
  const DataTableDemo({super.key});

  @override
  DataTableDemoState createState() => DataTableDemoState();
}

class DataTableDemoState extends State<DataTableDemo> {

  final List _data = [
    {'date': DateTime.now(), 'age': '30', 'city': '购买积分'},
    {'date': DateTime.now(), 'age': '2400', 'city': '购买月会员'},
    {'date': DateTime.now(), 'age': '35', 'city': '购买年会员'},
    {'date': DateTime.now(), 'age': '30', 'city': '购买积分'},
    {'date': DateTime.now(), 'age': '2400', 'city': '购买月会员'},
    {'date': DateTime.now(), 'age': '35', 'city': '购买年会员'},    {'date': DateTime.now(), 'age': '30', 'city': '购买积分'},
    {'date': DateTime.now(), 'age': '2400', 'city': '购买月会员'},
    {'date': DateTime.now(), 'age': '35', 'city': '购买年会员'},    {'date': DateTime.now(), 'age': '30', 'city': '购买积分'},
    {'date': DateTime.now(), 'age': '2400', 'city': '购买月会员'},
    {'date': DateTime.now(), 'age': '35', 'city': '购买年会员'},    {'date': DateTime.now(), 'age': '30', 'city': '购买积分'},
    {'date': DateTime.now(), 'age': '2400', 'city': '购买月会员'},
    {'date': DateTime.now(), 'age': '35', 'city': '购买年会员'},    {'date': DateTime.now(), 'age': '30', 'city': '购买积分'},
    {'date': DateTime.now(), 'age': '2400', 'city': '购买月会员'},
    {'date': DateTime.now(), 'age': '35', 'city': '购买年会员'},    {'date': DateTime.now(), 'age': '30', 'city': '购买积分'},
    {'date': DateTime.now(), 'age': '2400', 'city': '购买月会员'},
    {'date': DateTime.now(), 'age': '35', 'city': '购买年会员'},    {'date': DateTime.now(), 'age': '30', 'city': '购买积分'},
    {'date': DateTime.now(), 'age': '2400', 'city': '购买月会员'},
    {'date': DateTime.now(), 'age': '35', 'city': '购买年会员'},    {'date': DateTime.now(), 'age': '30', 'city': '购买积分'},
    {'date': DateTime.now(), 'age': '2400', 'city': '购买月会员'},
    {'date': DateTime.now(), 'age': '35', 'city': '购买年会员'},    {'date': DateTime.now(), 'age': '30', 'city': '购买积分'},
    {'date': DateTime.now(), 'age': '2400', 'city': '购买月会员'},
    {'date': DateTime.now(), 'age': '35', 'city': '购买年会员'},    {'date': DateTime.now(), 'age': '30', 'city': '购买积分'},
    {'date': DateTime.now(), 'age': '2400', 'city': '购买月会员'},
    {'date': DateTime.now(), 'age': '35', 'city': '购买年会员'},    {'date': DateTime.now(), 'age': '30', 'city': '购买积分'},
    {'date': DateTime.now(), 'age': '2400', 'city': '购买月会员'},
    {'date': DateTime.now(), 'age': '35', 'city': '购买年会员'},    {'date': DateTime.now(), 'age': '30', 'city': '购买积分'},
    {'date': DateTime.now(), 'age': '2400', 'city': '购买月会员'},
    {'date': DateTime.now(), 'age': '35', 'city': '购买年会员'},    {'date': DateTime.now(), 'age': '30', 'city': '购买积分'},
    {'date': DateTime.now(), 'age': '2400', 'city': '购买月会员'},
    {'date': DateTime.now(), 'age': '35', 'city': '购买年会员'},    
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('积分获得记录'),
      ),
      // body: SingleChildScrollView( // Important for scrollable content
      //   child: ConstrainedBox(
      //     constraints: const BoxConstraints(minWidth: double.infinity),
      //     child: DataTable(
      //       // columns: const <DataColumn>[
      //       //   DataColumn(label: Text('日期')),
      //       //   DataColumn(label: Text('获得积分')),
      //       //   DataColumn(label: Text('来源')),
      //       // ],
      //       columns: [],
      //       rows: _data
      //           .map(
      //             (item) => DataRow(
      //               cells: <DataCell>[
      //                 DataCell(Text(HBaseUtils.dateFormatter.format(item['date'].toLocal()))),
      //                 DataCell(Text(item['age']!)),
      //                 DataCell(Text(item['city']!)),
      //               ],
      //             ),
      //           )
      //           .toList(),
      //     ),
      //   ),
      // ),
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          // 返回一个 Sliver 数组给外部可滚动组件。
          return <Widget>[
            SliverAppBar(
              /// 隐藏回退按钮，必须隐藏，否则 header 布局会被回退按钮的空间所影响导致布局调整不准确
              automaticallyImplyLeading: false,  
              title: header(),
              pinned: true, // 固定在顶部
              titleSpacing: 0,
              titleTextStyle: TextStyle(fontSize: sp(16)),
            ),
          ];
        },
        body: rows()
      )
    );
  }

  header() {
    return Column(
      children: [
        Flex(
          direction: Axis.horizontal,
          children: [
            Expanded(
              flex: 3,
              child: Padding(
                padding: EdgeInsets.only(left: sp(20), right: sp(8)),
                child: const Text('日期'),
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: sp(8)),
                child: const Align(alignment: Alignment.centerRight, child: Text('获得积分')),
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: sp(8)),
                child: const Align(alignment: Alignment.centerLeft, child: Text('来源')),
              ),
            ),                  
          ]
        )
      ]
    );   
  }

  rows() {
    return SingleChildScrollView(
      child: Column(
        children: _data.map((item) =>
          Column(
            children: [
              const Divider(thickness: 0.5,),
              Flex(
                direction: Axis.horizontal,
                children: [
                  Expanded(
                    flex: 3,
                    child: Padding(
                      padding: EdgeInsets.only(left: sp(20), right: sp(8)),
                      child: Text(HBaseUtils.dateFormatter.format(item['date'].toLocal())),
                    )
                  ),
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: sp(8)),
                      child: Align(alignment: Alignment.centerRight, child: Text(item['age']!)),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: sp(8)),
                      child: Align(alignment: Alignment.centerLeft, child: Text(item['city']!)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ).toList(),
      ),
    );
  }
}