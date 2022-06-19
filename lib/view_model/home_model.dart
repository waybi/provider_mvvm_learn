import 'package:flutter_demo/model/article.dart';
import 'package:flutter_demo/model/banner.dart';
import 'package:flutter_demo/provider/view_state_refresh_list_model.dart';
import 'package:flutter_demo/service/wan_android_repository.dart';

import 'favourite_model.dart';

class HomeModel extends ViewStateRefreshListModel {
  late List<Banner> _banners;
  late List<Article> _topArticles = [];

  List<Banner> get banners => _banners;

  List<Article> get topArticles => _topArticles;

  @override
  Future<List> loadData({int? pageNum}) async {
    List<Future> futures = [];
    if (pageNum == ViewStateRefreshListModel.pageNumFirst) {
      futures.add(WanAndroidRepository.fetchBanners());
      futures.add(WanAndroidRepository.fetchTopArticles());
    }
    futures.add(WanAndroidRepository.fetchArticles(pageNum ?? 0));

    var result = await Future.wait(futures);
    if (pageNum == ViewStateRefreshListModel.pageNumFirst) {
      _banners = result[0];
      _topArticles = result[1];
      return result[2];
    } else {
      return result[0];
    }
  }

  @override
  onCompleted(List data) {
    GlobalFavouriteStateModel.refresh(data);
  }
}
