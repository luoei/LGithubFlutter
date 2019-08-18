import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:github/common/dao/repository_detail_dao.dart';
import 'package:github/common/model/Event.dart';
import 'package:github/common/model/RepoCommit.dart';
import 'package:github/common/model/Repository.dart';
import 'package:github/common/style/ui_style.dart';
import 'package:github/common/utils/common_utils.dart';
import 'package:github/repository_detail_info_header_page.dart';
import 'package:github/repository_detail_info_segement_page.dart';

class RepositoryDetailInfoPage extends StatefulWidget {
  // 用户名
  final String userName;

  // 仓库名
  final String repoName;

  // 分支名
  final String branchName;

  RepositoryDetailInfoPage({Key key, this.userName, this.repoName, this.branchName}) : super(key : key);

  @override
  State<StatefulWidget> createState() => _RepositoryDetailInfoState();
}

class _RepositoryDetailInfoState extends State<RepositoryDetailInfoPage>
    with AutomaticKeepAliveClientMixin<RepositoryDetailInfoPage> {

  bool _isRefreshing = false;

  bool _isLoadingMore = false;

  final GlobalKey<RefreshIndicatorState> _refreshInfoIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();

  ScrollController _scrollController = new ScrollController();

  var _pageNo = 1;

  List _dataSource;

  String _currentBranch = "master";

  Repository _repository;
  
  int _currentSelectedIndex = 0;

  // 默认大小
  double _headerHeight = 220;

  @override
  void initState() {
    super.initState();

    _loadDataForInfo();
    _loadFirstData();
    _scrollController.addListener(_updateScrollPosition);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_updateScrollPosition);
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;

  void _updateScrollPosition() {
    double offsetPixels = _scrollController.position.pixels;
    bool isBottom = offsetPixels == _scrollController.position.maxScrollExtent;
    if (!_isLoadingMore && isBottom && !_isRefreshing) {
//      setState(() {
        _loadMoreData();
//      });
    }
//    print('ScrollView offset: ${offsetPixels}');
  }

  Future _loadFirstData() async {
    if (!_isRefreshing) {
      _pageNo = 1;
      _isRefreshing = true;
      _isLoadingMore = false;
      return _loadData(_pageNo);
    }
  }

  Future _loadMoreData() async {
    if (!_isLoadingMore) {
      _isRefreshing = false;
      _isLoadingMore = true;
      return _loadData(_pageNo + 1);
    }
  }

  Future _loadDataForInfo() async{
    return RepositoryDetailDao.getRepositoryDetailInfo(widget.userName, widget.repoName, _currentBranch).then((data) {
        if (null != data) {
          _repository = data;
          setState(() {});
        }
    });
  }

  Future _loadData(int pageNo) async {
    if (_currentSelectedIndex == 1 ){
      return RepositoryDetailDao.getReposCommitsDao(widget.userName, widget.repoName, page: pageNo).then((data){
        if (pageNo < 2 || _dataSource == null || _dataSource.length == 0) {
          _dataSource = data;
        } else {
          if ((data as List).length > 0) {
            _pageNo = pageNo;
            _dataSource.addAll(data);
          }
        }
        _isRefreshing = false;
        _isLoadingMore = false;
        setState(() {});
      });
    }
    return RepositoryDetailDao.getRepositoryEventDao(widget.userName, widget.repoName , page: pageNo).then((data) {
      if (pageNo < 2 || _dataSource == null || _dataSource.length == 0) {
        _dataSource = data;
      } else {
        if ((data as List).length > 0) {
          _pageNo = pageNo;
          _dataSource.addAll(data);
        }
      }
      _isRefreshing = false;
      _isLoadingMore = false;
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    var resultView = (_repository == null
        ? SpinKitThreeBounce(
            color: Colors.black54,
            size: 30,
          )
        : _bodyView(context));
    return Scaffold(
      body: RefreshIndicator(
        key: _refreshInfoIndicatorKey,
        child: resultView,
        onRefresh: _loadFirstData,
      ),
    );
  }

  Widget _bodyView(BuildContext context) {
    return CustomScrollView(
      controller: _scrollController,
      slivers: <Widget>[
        SliverPersistentHeader(
//          pinned: true,
          delegate: _SliverRepositoryDetailInfoHeaderDelegate(
            minHeight: _headerHeight,
            maxHeight: _headerHeight,
            child: new RepositoryDetailInfoHeaderPage(
              repository: _repository,
              layoutListener: (size){
//                setState(() {
//                  _headerHeight = size.height;
//                });
              },
            ),
          ),
        ),
        SliverPersistentHeader(
          pinned: true,
          delegate: _StickySliverPersistentDelegate(
            indexChanged: (index){
              if(_currentSelectedIndex == index) return;
              _currentSelectedIndex = index;
              new Future.delayed(Duration(seconds: 0), (){
                _refreshInfoIndicatorKey.currentState.show();
                return true;
              });
            }
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) => _listItem(context, index),
            childCount: (_dataSource != null
                ? _dataSource.length + 1
                : 0),
          ),
        ),
      ],
    );
  }

  Widget _listItem(BuildContext context, int index) {
    if (index == _dataSource.length) {
      return new Container(
        alignment: Alignment.center,
        padding: EdgeInsets.all(5.0),
        child: new SizedBox(
          height: 40.0,
          width: 40.0,
          child: new Opacity(
            opacity: _isLoadingMore ? 1.0 : 0,
            child: new CircularProgressIndicator(),
          ),
        ),
      );
    } else {
      if (_currentSelectedIndex == 1){
        return _ListCommitItem(context, _dataSource[index]);
      }else{
        return _ListEventItem(context, _dataSource[index]);
      }
    }
  }

  Widget _ListEventItem(BuildContext context, Event item) {
    return new Container(
      child: new Card(
        elevation: 3.0,
        margin: EdgeInsets.all(10.0),
        shape: new RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(4.0))),
        color: Colors.white,
        child: new FlatButton(
          onPressed: null,
          child: new Padding(
            padding:
                new EdgeInsets.only(left: 0, top: 10.0, right: 0, bottom: 10.0),
            child: new Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                new Row(
                  children: <Widget>[
                    new ClipOval(
                      child: CachedNetworkImage(
                        imageUrl: item.actor.avatarUrl,
                        width: 30,
                        height: 30,
                        placeholder: (context, url) => Image(
                          image: new AssetImage(UIcons.DEFAULT_AVATAR),
                          width: 30,
                          height: 30,
                        ),
                      ),
                    ),
                    new Padding(padding: EdgeInsets.only(left: 10.0)),
                    new Expanded(
                        child: new Text(
                      item.actor.login,
                      style: new TextStyle(
                        fontSize: 20.0,
                        color: Colors.black87,
                      ),
                    )),
                    new Text(CommonUtils.getNewsTimeStr(item.createdAt))
                  ],
                ),
                new Container(
                  child: new Text(
                    item.actionDesc,
                    style: new TextStyle(
                      color: Colors.black54,
                    ),
                  ),
                  margin: new EdgeInsets.only(top: 6.0, bottom: 2.0),
                  alignment: Alignment.topLeft,
                ),
//                        new Padding(padding: EdgeInsets.all(20.0)),
                ((item.desc == null || item.desc.length == 0)
                    ? new Container()
                    : new Container(
                        child: new Text(
                          item.desc,
                          maxLines: 3,
                        ),
                        margin: new EdgeInsets.only(top: 6.0, bottom: 2.0),
                        alignment: Alignment.topLeft,
                      )),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _ListCommitItem(BuildContext context, RepoCommit item) {
    return new Container(
      child: new Card(
        elevation: 3.0,
        margin: EdgeInsets.all(10.0),
        shape: new RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(4.0))),
        color: Colors.white,
        child: new FlatButton(
          onPressed: null,
          child: new Padding(
            padding:
            new EdgeInsets.only(left: 0, top: 10.0, right: 0, bottom: 10.0),
            child: new Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                new Row(
                  children: <Widget>[
                    new Expanded(
                        child: new Text(
                          item.commit.author.name,
                          style: new TextStyle(fontSize: 15.0, color: Colors.black87,),
                        )),
                    new Text(CommonUtils.getNewsTimeStr(item.commit.committer.date))
                  ],
                ),
                new Container(
                  child: new Text(
                    item.commit.message,
                    style: new TextStyle(fontSize: 14.0, color: Colors.black54,),
                    maxLines: 2,
                  ),
                  margin: new EdgeInsets.only(top: 6.0, bottom: 2.0),
                  alignment: Alignment.topLeft,
                ),
                new Text('sha:item.sha', maxLines: 2,),
              ],
            ),
          ),
        ),
      ),
    );
  }

}

class _StickySliverPersistentDelegate extends SliverPersistentHeaderDelegate {

  final ValueChanged indexChanged;

  double widgetHeight = 60;

  _StickySliverPersistentDelegate({@required this.indexChanged});

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      margin: EdgeInsets.only(left: 10.0,right: 10.0),
      child: new RepositoryDetailInfoSegementPage(
        titles: ['动态','提交'],
        height: widgetHeight,
        selectedItemChanged: (index){
          indexChanged(index);
        },
      ),
    );
  }


  @override
  double get maxExtent => widgetHeight;

  @override
  double get minExtent => widgetHeight;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}

class _SliverRepositoryDetailInfoHeaderDelegate extends SliverPersistentHeaderDelegate {

  final double minHeight;

  final double maxHeight;

  final Widget child;

  _SliverRepositoryDetailInfoHeaderDelegate({@required this.minHeight,@required this.maxHeight, this.child});

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => math.max(minHeight, maxHeight);

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

}


