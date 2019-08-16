import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:github/common/dao/repository_detail_dao.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:github/common/style/ui_style.dart';
import 'package:github/common/utils/common_utils.dart';
import 'package:github/repository_detail_info_segement_page.dart';
import 'package:github/common/model/Issue.dart';
import 'package:github/common/config/config.dart';

class RepositoryDetailIssuePage extends StatefulWidget {
  // 用户名
  final String userName;

  // 仓库名
  final String repoName;

  // 分支名
  final String branchName;

  RepositoryDetailIssuePage({Key key, this.userName, this.repoName, this.branchName}) : super(key : key);

  @override
  State<StatefulWidget> createState() => _RepositoryDetailIssuePageState();
}

class _RepositoryDetailIssuePageState extends State<RepositoryDetailIssuePage>
    with AutomaticKeepAliveClientMixin<RepositoryDetailIssuePage> {

  bool _isRefreshing = false;

  bool _isLoadingMore = false;

  final GlobalKey<RefreshIndicatorState> _refreshInfoIndicatorKey =
  new GlobalKey<RefreshIndicatorState>();

  ScrollController _scrollController = new ScrollController();

  var _pageNo = 1;

  List _dataSource;

  String _currentBranch = "master";

  String _currentIssueState = null;

  int _currentSelectedIndex = 0;

  @override
  void initState() {
    super.initState();

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
      setState(() {
        _loadMoreData();
      });
    }
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

  Future _loadData(int pageNo) async {
    return RepositoryDetailDao.getRepositoryIssueDao(widget.userName, widget.repoName, _currentIssueState, page: pageNo).then((data){
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

  ///切换显示状态
  _resolveSelectIndex() {
    switch (_currentSelectedIndex) {
      case 0:
        _currentIssueState = null;
        break;
      case 1:
        _currentIssueState = 'open';
        break;
      case 2:
        _currentIssueState = "closed";
        break;
    }

    ///回滚到最初位置
    _scrollController
        .animateTo(0,
        duration: Duration(milliseconds: 100), curve: Curves.bounceIn)
        .then((_) {
      new Future.delayed(Duration(seconds: 0), (){
        _refreshInfoIndicatorKey.currentState.show();
        return true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    var resultView = (_dataSource == null
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
          delegate: _SliverRepositoryDetailIssusHeaderDelegate(
            minHeight: 10,
            maxHeight: 10,
          ),
        ),
        SliverPersistentHeader(
          pinned: true,
          delegate: _StickySliverPersistentDelegate(
              indexChanged: (index){
                if(_currentSelectedIndex == index) return;
                _currentSelectedIndex = index;
                _resolveSelectIndex();
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
      return _ListContentItem(context, _dataSource[index]);
    }
  }

  Widget _ListContentItem(BuildContext context, Issue item) {
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
                        imageUrl: item.user.avatarUrl,
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
                          item.user.login,
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
                    item.title,
                    style: new TextStyle(
                      color: Colors.black54,
                    ),
                    maxLines: 2,
                  ),
                  margin: new EdgeInsets.only(top: 6.0, bottom: 2.0),
                  alignment: Alignment.topLeft,
                ),
                Padding(padding: EdgeInsets.only(top: 5.0),),
                new Row(
                  children: <Widget>[
                    _listItemPictureLabel(context,const IconData(0xe661, fontFamily: Config.FONT_FAMILY), item.state, item.state == 'open' ? Colors.green : Colors.red),
                    Padding(padding: EdgeInsets.only(left: 5.0)),
                    Expanded(
                      child: Text('#${item.number}'),
                    ),
                    _listItemPictureLabel(context,const IconData(0xe6ba, fontFamily: Config.FONT_FAMILY), item.commentNum.toString(), Colors.grey),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _listItemPictureLabel(BuildContext context, IconData iconData, String text, Color color) {
    return Container(
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(iconData, size: 15, color: color,),
            Padding(padding: EdgeInsets.only(left: 5.0)),
            new Container(
              child: Text(text, style: TextStyle(fontSize: 13, color: color), overflow: TextOverflow.ellipsis,),
            )
          ],
        ),
      ),
    );
  }

}

class _StickySliverPersistentDelegate extends SliverPersistentHeaderDelegate {

  final ValueChanged indexChanged;

  double widgetHeight = 50;

  _StickySliverPersistentDelegate({@required this.indexChanged});

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      margin: EdgeInsets.only(left:10.0, right: 10.0),
      child: new RepositoryDetailInfoSegementPage(
        titles: ['所有','打开','关闭'],
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

class _SliverRepositoryDetailIssusHeaderDelegate extends SliverPersistentHeaderDelegate {

  final double minHeight;

  final double maxHeight;

  _SliverRepositoryDetailIssusHeaderDelegate({@required this.minHeight,@required this.maxHeight});

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => maxHeight;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
    );
  }

}
