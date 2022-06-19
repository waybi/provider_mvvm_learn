import 'package:flutter/material.dart'
    hide SliverAnimatedListState, SliverAnimatedList;
import 'package:flutter_demo/config/router_manger.dart';
import 'package:flutter_demo/flutter/refresh_animatedlist.dart';
import 'package:flutter_demo/generated/l10n.dart';
import 'package:flutter_demo/model/article.dart';
import 'package:flutter_demo/provider/provider_widget.dart';
import 'package:flutter_demo/provider/view_state_widget.dart';
import 'package:flutter_demo/ui/helper/refresh_helper.dart';
import 'package:flutter_demo/ui/widget/article_list_Item.dart';
import 'package:flutter_demo/ui/widget/article_skeleton.dart';
import 'package:flutter_demo/ui/widget/skeleton.dart';
import 'package:flutter_demo/view_model/favourite_model.dart';
import 'package:flutter_demo/view_model/login_model.dart';
// import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

/// 必须为StatefulWidget,才能根据[GlobalKey]取出[currentState].
/// 否则从详情页返回后,无法移除没有收藏的item
class FavouriteListPage extends StatefulWidget {
  @override
  _FavouriteListPageState createState() => _FavouriteListPageState();
}

class _FavouriteListPageState extends State<FavouriteListPage> {
  final GlobalKey<SliverAnimatedListState> listKey =
      GlobalKey<SliverAnimatedListState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).myFavourites),
      ),
      body: ProviderWidget<FavouriteListModel>(
        model: FavouriteListModel(loginModel: LoginModel(Provider.of(context))),
        onModelReady: (model) async {
          await model.initData();
        },
        builder: (context, FavouriteListModel model, child) {
          if (model.isBusy) {
            return SkeletonList(
              builder: (context, index) => ArticleSkeletonItem(),
            );
          } else if (model.isEmpty) {
            return ViewStateEmptyWidget(onPressed: model.initData);
          } else if (model.isError) {
            if (model.viewStateError.isUnauthorized) {
              return ViewStateUnAuthWidget(onPressed: () async {
                var success =
                    await Navigator.of(context).pushNamed(RouteName.login);
                // 登录成功,获取数据,刷新页面
                if (success != null) {
                  model.initData();
                }
              });
            } else if (model.list.isEmpty) {
              // 只有在页面上没有数据的时候才显示错误widget
              return ViewStateErrorWidget(
                  error: model.viewStateError, onPressed: model.initData);
            }
          }
          return SmartRefresher(
              controller: model.refreshController,
              header: WaterDropHeader(),
              footer: RefresherFooter(),
              onRefresh: () async {
                await model.refresh();
                listKey.currentState?.refresh(model.list.length);
              },
              onLoading: () async {
                await model.loadMore();
                listKey.currentState?.refresh(model.list.length);
              },
              enablePullUp: true,
              child: CustomScrollView(slivers: <Widget>[
                SliverAnimatedList(
                    key: listKey,
                    initialItemCount: model.list.length,
                    itemBuilder: (context, index, animation) {
                      Article item = model.list[index];
                      return Slidable(
                        // startActionPane: SlidableDrawerActionPane(),
                        startActionPane: ActionPane(
                          // A motion is a widget used to control how the pane animates.
                          motion: const ScrollMotion(),

                          // A pane can dismiss the Slidable.
                          dismissible: DismissiblePane(onDismissed: () {}),

                          // All actions are defined in the children parameter.
                          children: [
                            // A SlidableAction can have an icon and/or a label.
                            SlidableAction(
                              onPressed: doNothing,
                              backgroundColor: Color(0xFFFE4A49),
                              foregroundColor: Colors.white,
                              icon: Icons.delete,
                              label: 'Delete',
                            ),
                            SlidableAction(
                              onPressed: doNothing,
                              backgroundColor: Color(0xFF21B7CA),
                              foregroundColor: Colors.white,
                              icon: Icons.share,
                              label: 'Share',
                            ),
                          ],
                        ),

                        // The
                        // secondaryActions: <Widget>[
                        //   IconSlideAction(
                        //     caption: S.of(context).collectionRemove,
                        //     color: Colors.redAccent,
                        //     icon: Icons.delete,
                        //     onTap: () {
                        //       FavouriteModel(
                        //               globalFavouriteModel:
                        //                   Provider.of(context, listen: false))
                        //           .collect(item);
                        //       removeItem(model.list, index);
                        //     },
                        //   )
                        // ],
                        child: SizeTransition(
                            axis: Axis.vertical,
                            sizeFactor: animation,
                            child: ArticleItemWidget(
                              item,
                              hideFavourite: true,
                              onTap: () async {
                                await Navigator.of(context).pushNamed(
                                    RouteName.articleDetail,
                                    arguments: item);
                                if (!(item.collect)) {
                                  removeItem(model.list, index);
                                }
                              },
                            )),
                      );
                    })
              ]));
        },
      ),
    );
  }

  void doNothing(BuildContext context) {}

  /// 移除取消收藏的item
  removeItem(List list, int index) {
    var removeItem = list.removeAt(index);
    listKey.currentState?.removeItem(
        index,
        (context, animation) => SizeTransition(
            axis: Axis.vertical,
            axisAlignment: 1.0,
            sizeFactor: animation,
            child: ArticleItemWidget(
              removeItem,
              hideFavourite: true,
            )));
  }
}
