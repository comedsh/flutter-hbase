# Paging 总结

再次使用 infinite_scroll_pagination 的 PagingController 算是收获满满，这才算是把它给搞明白了；分页无非就是分页的 loading 状态维护，加载分页失败了又该如何处理，PagingController 通通将这些问题都解决了，下面一一展开描述

1. 当你使用了 PagingController 之后就无需自己再动手去实现 loading 的逻辑了，通通交给 PagingController 和 firstPageProgressIndicatorBuilder + newPageErrorIndicatorBuilder 搞定，newPageErrorIndicatorBuilder 即是下一页的 loading 控件默认使用的就是 CircularProgressIndicator 因此默认情况下无需重装，最多 firstPageProgressIndicatorBuilder 需要使用 skeleton 重载一下即可；
2. 并且当分页失败，获得第一页失败的时候直接使用 firstPageErrorIndicatorBuilder 属性，使用 FailRetrier(callback: pagingController.refresh) 实现即可，pagingController.refresh 厉害的地方在于，它会重置第一页 loading 的状态，重新加载；如果不是第一页分页失败的话，使用 
   ```dart
   newPageErrorIndicatorBuilder: (context) => 
          NewPageErrorIndicator(
            errMsg: '网络异常，点击重试',
            onTap: () => pagingController.retryLastFailedRequest()),
   ```
   其中 pagingController.retryLastFailedRequest 就是从上一次分页失败的页面重新进行加载。
3. 没有数据的情况，一种是第一页就没有数据，使用 noItemsFoundIndicatorBuilder 构建，如果没有更多数据则使用 noMoreItemsIndicatorBuilder；
   
HotspotCardListView 是一个非常好的 demo，没事的时候多看看。