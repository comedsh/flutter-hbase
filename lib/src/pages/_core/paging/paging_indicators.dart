import 'package:flutter/material.dart';

/// 实现 newPageErrorIndicatorBuilder 所需要的组件，即非第一页分页失败使用的组件，
/// 如何使用参考 HotspotCardListView
/// 实现：直接 copy [infinite_scroll_pagination] 的 [NewPageErrorIndicator] 组件
class NewPageErrorIndicator extends StatelessWidget {
  final String errMsg;
  final VoidCallback? onTap;

  const NewPageErrorIndicator({
    super.key,
    this.errMsg = 'Something went wrong. Tap to try again.',
    this.onTap, 
  });

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    child: __FooterTile(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            errMsg,
            textAlign: TextAlign.center,
          ),
          const SizedBox(
            height: 4,
          ),
          const Icon(
            Icons.refresh,
            size: 16,
          ),
        ],
      ),
    ),
  );
}

class __FooterTile extends StatelessWidget {
  const __FooterTile({
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(
      top: 16,
      bottom: 16,
    ),
    child: Center(child: child),
  );
}
