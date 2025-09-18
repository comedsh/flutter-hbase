import 'package:flutter/material.dart';
import 'package:hbase/hbase.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:sycomponents/components.dart';

class PointReceiptPage extends StatefulWidget {
  final Pager<PointReceipt> pager;
  const PointReceiptPage({super.key, required this.pager});

  @override
  PointReceiptPageState createState() => PointReceiptPageState();
}

class PointReceiptPageState extends State<PointReceiptPage> {
  final PagingController<int, PointReceipt> pagingController = PagingController(firstPageKey: 1);

  @override
  void initState() {
    super.initState();
    /// 监听分页回调，注意参数 pageKey 就是 PageNum，只是该值现在由框架维护了，干脆直接将 pageKey 更名为 pageNum
    /// 唯一需要特别注意的是 PagingController 会自动触发第一页的加载，因此无需手动的去触发第一页加载；
    pagingController.addPageRequestListener((pageNum) async {
      debugPrint('pagingController trigger the nextPage event with pageNum: $pageNum');
      await Paging.nextPage(pageNum, widget.pager, pagingController, context);
    });    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('积分获得记录'),
      ),
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
              flex: 4,
              child: Padding(
                padding: EdgeInsets.only(left: sp(20), right: sp(8)),
                child: const Text('日期'),
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: sp(8)),
                child: const Align(
                  alignment: Alignment.centerRight, 
                  child: Text('获得积分')
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: sp(8)),
                child: const Align(
                  alignment: Alignment.centerLeft, 
                  child: Text('来源')
                ),
              ),
            ),                  
          ]
        )
      ]
    );   
  }

  rows() {
    return PagedListView<int, PointReceipt>(
        pagingController: pagingController,
        builderDelegate: PagedChildBuilderDelegate<PointReceipt>(
          // 加载第一页时候的使用的 loading 组件
          firstPageProgressIndicatorBuilder: (context) => const Center(child: CircularProgressIndicator()),
          // 直接使用 pagingController.refresh 即可重新触发 firstPageProgressIndicatorBuilder 的 loading 过程
          firstPageErrorIndicatorBuilder: (context) => FailRetrier(callback: pagingController.refresh),
          // 如果加载下一页失败后使用的 reloading 组件
          newPageErrorIndicatorBuilder: (context) => 
            NewPageErrorIndicator(
              errMsg: '网络异常，点击重试',
              onTap: () => pagingController.retryLastFailedRequest()),
          // 第一页就没有数据时候所使用的组件
          noItemsFoundIndicatorBuilder: (context) => const Center(child: Text('没有数据'),),
          itemBuilder: (context, pointReceipt, index) => 
            Column(
              children: [
                const Divider(thickness: 0.5,),
                Flex(
                  direction: Axis.horizontal,
                  children: [
                    Expanded(
                      flex: 4,
                      child: Padding(
                        padding: EdgeInsets.only(left: sp(20), right: sp(8)),
                        child: Text(HBaseUtils.dateFormatterHhmm.format(pointReceipt.createTs.toLocal())),
                      )
                    ),
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: sp(8)),
                        child: Align(alignment: Alignment.centerRight, child: Padding(
                          padding: EdgeInsets.only(right: sp(4)),
                          child: Text(pointReceipt.points.toString()),
                        )),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: sp(8)),
                        child: Align(alignment: Alignment.centerLeft, child: Text(pointReceipt.receiveDesc)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
        )
    );
  }
}