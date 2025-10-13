enum UserAuthority {
  unlockBlur,
  showPicDownload,
  showVideoDownload,
  unlockSingleSale,
  unlockSubscrSale,
  unlockPointSale,
  unlockTranslation,
  /// 一种随机性的打分；比如在用户翻页、打开 app 后的普通行为中产生
  unlockScoreSimple,
  /// 一种目的性的打分；比如用户喜欢、收藏、关注过程中展示，这种方式是跳转到 appstore 进行评论评分
  unlockScoreTarget,
  /// 是否允许评分后下载
  unlockScoreToDownload,
}
