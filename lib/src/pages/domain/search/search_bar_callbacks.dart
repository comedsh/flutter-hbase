import 'dart:async';

import 'package:appbase/appbase.dart';
import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:get/get.dart';
import 'package:hbase/hbase.dart';
// ignore: depend_on_referenced_packages
import 'package:sycomponents/components.dart';
import 'package:sypages/pages.dart';


Widget flashPageCreator(TextEditingController textEditingController) {

  SearchStateController searchStateController = Get.find();

  // ignore: unused_element, no_leading_underscores_for_local_identifiers
  List<Widget> __getMockHotSearchKeywords(BuildContext context) {
    return [
      OutlinedButton(onPressed: () {
        triggerKeywordChosedSearchResultNotification(
          "Apple", textEditingController, searchStateController, context);
      }, child: const Text("Apple")),
      OutlinedButton(onPressed: () {
        triggerKeywordChosedSearchResultNotification(
          "Banana", textEditingController, searchStateController, context);
      }, child: const Text("Banana")),
      OutlinedButton(onPressed: () {
        triggerKeywordChosedSearchResultNotification(
          "Ap", textEditingController, searchStateController, context);
      }, child: const Text("Ap")),
      OutlinedButton(onPressed: () {
        triggerKeywordChosedSearchResultNotification(
          "Fig", textEditingController, searchStateController, context);
      }, child: const Text("Fig")),
      OutlinedButton(onPressed: () {
        triggerKeywordChosedSearchResultNotification(
          "Apple", textEditingController, searchStateController, context);
      }, child: const Text("Orange")),
      OutlinedButton(onPressed: () {
        triggerKeywordChosedSearchResultNotification(
          "Banana", textEditingController, searchStateController, context);
      }, child: const Text("Milk")),
      OutlinedButton(onPressed: () {
        triggerKeywordChosedSearchResultNotification(
          "Ap", textEditingController, searchStateController, context);
      }, child: const Text("Pear"))
    ];
  }

  // ignore: no_leading_underscores_for_local_identifiers
  List<Widget> _getHotSearchKeywords(BuildContext context) {
    // return __getMockHotSearchKeywords(context);
    List<String> searchHotKeywords = (AppServiceManager.appConfig.display as HBaseDisplay).searchHotKeywords!;
    late List<String> searchKeyWordsToDisplay;

    /// 如果超过了 12 个热门搜索关键词，那么随机从中抽取 12 个关键词以展示
    if (searchHotKeywords.length > 12) {
      // Create a copy of the list to avoid modifying the original
      List<String> shuffledItems = List.from(searchHotKeywords);
      // Shuffle the list randomly
      shuffledItems.shuffle();
      int numberOfRandomElements = 12;
      searchKeyWordsToDisplay = shuffledItems.take(numberOfRandomElements).toList();    
    } else {
      searchKeyWordsToDisplay = searchHotKeywords;
    }

    return searchKeyWordsToDisplay.map((word) => 
      OutlinedButton(
        onPressed: () {
          triggerKeywordChosedSearchResultNotification(
            word, textEditingController, searchStateController, context);
        }, 
        // 强悍，使用下面这个方式设置颜色，就可以自动的感知 light/dark model 的变化了
        child: Text(word, style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color,),)
      )
    ).toList(); 
  }

  return Builder(
    builder: (context) {
      return Container(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            const Row(
              children: [
                Text("热门搜索", style: TextStyle(fontSize: 22),)
              ],
            ),
            SizedBox(height: sp(14.0)),
            /// 使用 [Wrap] 比 [Row] 更好的地方在于，children 不会导致 row 溢出而是会自动换行
            Wrap(
              spacing: sp(12.0), // gap between items
              runSpacing: sp(6.0), // gap between lines              
              children: _getHotSearchKeywords(context),
            )
          ],
        )
      );
    }
  );
}

KeywordsListPage searchKeywordListPage(TextEditingController controller) {
  return KeywordsListPage(
    textEditingController: controller,
    fetchKeywordObjsCallback: (String? keyword) async {
      keyword = keyword ?? ""; // resolve keyword nullable.
      var r = await dio.post('/search/match-tokens', data: {"token": keyword});
      var tokens = r.data;
      return tokens;
    },
    listTileCreator: (String obj, BuildContext context) {
      return defaultStatefulListTileCreator(obj, context);
    }                          
  );
}

KeywordsListPage mockKeywordListPage(TextEditingController controller) {
  return KeywordsListPage(
    textEditingController: controller,
    fetchKeywordObjsCallback: (String? keyword) async {
      keyword = keyword ?? ""; // resolve keyword nullable.
      Completer<List<String>> completer = Completer();
      final List<String> data = [
        'Apple',
        'Banana',
        'Cherry',
        'Date',
        'Fig',
        'Grape',
        'Lemon',
        'Mango',
        'Orange',
        'Papaya',
        'Peach',
        'Plum',
        'Raspberry',
        'Strawberry',
        'Watermelon',
      ];
      await 1.delay();
      var results = data.where(
        (element) => element
          .toLowerCase()
          .contains(keyword!.toLowerCase())
        ).toList();
      completer.complete(results);
      return completer.future;
    },
    listTileCreator: (String obj, BuildContext context) {
      return defaultStatefulListTileCreator(obj, context);
    }                          
  );
}

Widget? searchPostResultPageCreator({required String keyword, List<String>? chnCodes}) {
  debugPrint('searchPostResultPageCreator, keyword: $keyword');
  var postPager = SearchPostPager(
    token: keyword,
    chnCodes: chnCodes, 
    pageSize: 24,
  );  
  return PostAlbumListView(
    postPager: postPager, 
    isEnableAutoScroll: true,
    onCellTapped: (posts, post, postPager) async =>
      /// 当点击 cell 后会跳转到第三方页面，这里的返回值 index 是从第三方页面返回时的 post index，
      /// 这样 PostAlbumListView 根据这个值就可以进行 scrollTo 操作了
      await Get.to<int>(() => 
        PostFullScreenListViewPage(
          posts: posts, 
          post: post, 
          postPager: postPager,
          title: keyword
        )) 
  );  
}

Widget? searchProfileResultPageCreator({required String keyword, List<String>? chnCodes}) {
  debugPrint('searchProfileResultPageCreator, keyword: $keyword');
  var profilePager = SearchProfilePager(
    token: keyword,
    chnCodes: chnCodes,
    pageSize: 24,
  );

  /// 下面的 key 是随着输入显示查询结果能够更新视图的关键，否则 Flutter 会认为 key 相同而不予更新视图，进而
  /// 无法动态的更新视图
  return ProfileListView(pager: profilePager, key: Key("PLV_${DateTime.timestamp()}"));  
}

Widget? mockSearchResultPageCreator(String keyword) {
  debugPrint('mockSearchResultPageCreator has been called with keyword: $keyword');

  return Container(
    padding: const EdgeInsets.all(10.0),
    child: Center(
        child: Text('this is search result for keyword: $keyword'),
      ),
  );

}