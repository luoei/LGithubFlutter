import 'package:flutter/material.dart';
import 'package:github/common/dao/dynamic_dao.dart';
import 'package:github/common/model/dynamic_item_entity.dart';
import 'package:github/common/utils/common_utils.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:github/common/style/ui_style.dart';
import 'package:dropdown_menu/dropdown_menu.dart';
import 'package:github/repository_detail_page.dart';
import 'package:github/common/dao/dao_result.dart';

class DynamicPage extends StatefulWidget {

  @override
  State<StatefulWidget> createState() => _DynamicPageState();

}



class _DynamicPageState extends State<DynamicPage> with WidgetsBindingObserver, AutomaticKeepAliveClientMixin<DynamicPage> {

  List<DynamicItemEntity> items;
  bool isRefreshing = false;
  bool isLoadingMore = false;
  final GlobalKey<RefreshIndicatorState> refreshIndicatorKey =new GlobalKey<RefreshIndicatorState>();
  ScrollController scrollController = new ScrollController();

  var _pageNo = 1;

//  var _futureBuilderFuture;

  @override
  void initState() {
    super.initState();
    ///监听生命周期，主要判断页面 resumed 的时候触发刷新
    WidgetsBinding.instance.addObserver(this);
    scrollController.addListener(_updateScrollPosition);
  }

  void _updateScrollPosition() {
    bool isBottom = scrollController.position.pixels ==
        scrollController.position.maxScrollExtent;
    if (!isLoadingMore && isBottom && !isRefreshing) {
      setState(() {
        _loadMoreData();
      });
    }
  }

  @override
  void didChangeDependencies() {

//    _futureBuilderFuture = DynamicDao.get(_pageNo);

    _loadData(_pageNo);

    super.didChangeDependencies();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {

    if (state == AppLifecycleState.resumed){

    }
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    scrollController.removeListener(_updateScrollPosition);
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    var resultView = (items == null ? SpinKitThreeBounce(color: Colors.black54, size: 30,) : _build(context));
    return Scaffold(
      appBar: AppBar(
        title: Text('动态'),
      ),
      body: RefreshIndicator(
        child: resultView,
        onRefresh: _loadFirstData,
      ),
    );
  }

  Future _loadFirstData() async {
    if (!isRefreshing){
      _pageNo = 1;
      isRefreshing = true;
      isLoadingMore = false;
      setState(() {});
      return _loadData(_pageNo);
    }
  }

  Future _loadMoreData() async {
    if (!isLoadingMore){
      isRefreshing = false;
      isLoadingMore = true;
      setState(() {});
      return _loadData(_pageNo+1);
    }
  }

  Future _loadData(int pageNo) async {
    return DynamicDao.get(pageNo).then((data){
      if(data.status == DataResultStatus.SUCESS){
        if (pageNo < 2 || items == null || items.length == 0){
          items = data.data;
        }else{
          items.addAll(data.data);
        }
        _pageNo = pageNo;
      }else{

      }
      isRefreshing = false;
      isLoadingMore = false;
      setState(() {});

    });
  }


  Widget _build(BuildContext context){
    return ListView.builder(
      controller: scrollController,
      key: refreshIndicatorKey,
      itemCount: null == items ? 0 : items.length+1,
      itemBuilder: (context, index) {
        if (index == items.length){
          return new Container(
            alignment: Alignment.center,
            padding: EdgeInsets.all(5.0),
            child: new SizedBox(
              height: 40.0,
              width: 40.0,
              child: new Opacity(
                opacity: isLoadingMore ? 1.0 : 0,
                child: new CircularProgressIndicator(),
              ),
            ),
          );
        }else{
          DynamicItemEntity item = items[index];
          return _ListItem(context, item, (){
            var reposName = item.repo.name.split("/");
            if(reposName == null || reposName.length == 0) {
              return;
            }
            String ownerName = reposName.first;
            String repoName = reposName.last;
            Navigator.push(context, MaterialPageRoute(builder: (context) => RepositoryDetailPage(userName: ownerName, repoName: repoName,)));
          });
        }
      },
      physics: const AlwaysScrollableScrollPhysics(),
    );
  }

  Widget _ListItem(BuildContext context, DynamicItemEntity item, VoidCallback onPressed) {
    return new Container(
      child: new Card(
        elevation: 5.0,
        margin: EdgeInsets.all(10.0),
        shape: new RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(4.0))),
        color: Colors.white,
        child: new FlatButton(
          onPressed: onPressed,
          child: new Padding(
            padding: new EdgeInsets.only(left: 0, top: 10.0, right: 0, bottom: 10.0),
            child: new Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                new Row(
                  children: <Widget>[
                    new ClipOval(
                      child: CachedNetworkImage(
                        imageUrl: item.actor.avatarUrl,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Image(image: new AssetImage(UIcons.DEFAULT_AVATAR), width: 50, height: 50,),
                      ),
                    ),
                    new Padding(padding: EdgeInsets.only(left: 10.0)),
                    new Expanded(child: new Text(item.actor.displayLogin, style: new TextStyle(
                      fontSize: 20.0,
                      color: Colors.black87,
                    ),)),
                    new Text(CommonUtils.getNewsTimeStr(item.createdAt))
                  ],
                ),
                new Container(
                  child: new Text(item.actionDesc, style: new TextStyle(
                    color: Colors.black54,
                  ),),
                  margin: new EdgeInsets.only(top: 6.0, bottom: 2.0),
                  alignment: Alignment.topLeft,
                ),
//                        new Padding(padding: EdgeInsets.all(20.0)),
                ((item.desc == null || item.desc.length == 0) ? new Container() : new Container(
                  child: new Text(
                    item.desc,
                    maxLines: 3,
                  ),
                  margin: new EdgeInsets.only(top: 6.0, bottom: 2.0),
                  alignment: Alignment.topLeft,
                ) ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
}