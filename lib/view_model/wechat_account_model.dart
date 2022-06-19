import 'package:flutter_demo/model/article.dart';
import 'package:flutter_demo/model/tree.dart';
import 'package:flutter_demo/provider/view_state_list_model.dart';
import 'package:flutter_demo/provider/view_state_refresh_list_model.dart';
import 'package:flutter_demo/service/wan_android_repository.dart';

import 'favourite_model.dart';

/// 微信公众号
class WechatAccountCategoryModel extends ViewStateListModel<Tree> {
  @override
  Future<List<Tree>> loadData() async {
    return await WanAndroidRepository.fetchWechatAccounts();
  }
}

/// 微信公众号文章
class WechatArticleListModel extends ViewStateRefreshListModel<Article> {
  /// 公众号id
  final int id;

  WechatArticleListModel(this.id);

  @override
  Future<List<Article>> loadData({int? pageNum}) async {
    return await WanAndroidRepository.fetchWechatAccountArticles(
        pageNum ?? 0, id);
  }

  @override
  onCompleted(List data) {
    GlobalFavouriteStateModel.refresh(data);
  }
}
