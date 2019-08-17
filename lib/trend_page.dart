import 'package:flutter/material.dart';
import 'package:github/common/model/TrendingRepoModel.dart';
import 'package:github/common/config/config.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:github/common/dao/trend_dao.dart';
import 'package:github/common/style/ui_style.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dropdown_menu/dropdown_menu.dart';
import 'package:github/repository_detail_page.dart';

class TrendPage extends StatefulWidget {

  @override
  State<StatefulWidget> createState() => _TrendPageState();

}

const List<Map<String, dynamic>> SINCE = [
  {"title": "今日", "key": "daily"},
  {"title": "本周", "key": "weekly"},
  {"title": "本月", "key": "monthly"},
];

int SINCE_INDEX = 0;

const List<Map<String, dynamic>> LANGUAGE_TYPE = [
  {"title": "全部", "key": "all"},
  {"title": "Java", "key": "Java"},
  {"title": "Kotlin", "key": "Kotlin"},
  {"title": "Dart", "key": "Dart"},
  {"title": "Objective-C", "key": "Objective-C"},
  {"title": "Swift", "key": "Swift"},
  {"title": "JavaScript", "key": "JavaScript"},
  {"title": "PHP", "key": "PHP"},
  {"title": "Go", "key": "Go"},
  {"title": "C++", "key": "C++"},
  {"title": "C", "key": "C"},
  {"title": "HTML", "key": "HTML"},
  {"title": "CSS", "key": "CSS"},
  {"title": "Python", "key": "Python"},
  {"title": "C#", "key": "c%23"},
];

int LANGUAGE_TYPE_INDEX = 0;

const double kDropdownMenuItemHeight = 50.0;

class _TrendPageState extends State<TrendPage> with WidgetsBindingObserver, AutomaticKeepAliveClientMixin<TrendPage> {

  List items;
  bool isRefreshing = false;
  bool isLoadingMore = false;
  final GlobalKey<RefreshIndicatorState> refreshIndicatorKey = new GlobalKey<RefreshIndicatorState>();
  ScrollController scrollController = new ScrollController();

  var _pageNo = 1;

//  var _futureBuilderFuture;

  @override
  void initState() {
    super.initState();
    ///监听生命周期，主要判断页面 resumed 的时候触发刷新
    WidgetsBinding.instance.addObserver(this);
    scrollController.addListener(_updateScrollPosition);
    _loadData(_pageNo);
  }

  void _updateScrollPosition() {
    bool isBottom = scrollController.position.pixels ==
        scrollController.position.maxScrollExtent;
    if (!isLoadingMore && isBottom && !isRefreshing) {
      _loadMoreData();
    }
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

  showRefreshLoading() {
    new Future.delayed(const Duration(seconds: 0), () {
      var state = refreshIndicatorKey.currentState;
      return true;
    });
  }

  @override
  Widget build(BuildContext context) {
    var resultView = (items == null ? SpinKitThreeBounce(color: Colors.black54, size: 30,) : _build(context));
    return Scaffold(
      appBar: AppBar(
        title: Text('趋势'),
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
      return _loadData(_pageNo);
    }
  }

  Future _loadMoreData() async {
    if (!isLoadingMore){
      isRefreshing = false;
      isLoadingMore = true;
      return _loadData(_pageNo+1);
    }
  }

  Future _loadData(int pageNo) async {
    String since = SINCE[SINCE_INDEX]['key'];
    String languageType = LANGUAGE_TYPE[LANGUAGE_TYPE_INDEX]['key'];
    if (languageType == "all") languageType = null;
    return TrendDao.getTrend(since: since, languageType: languageType).then((data){
      if (data != null){
        items = data;
        isRefreshing = false;
        isLoadingMore = false;
        _pageNo = pageNo;
      }else{

      }
        setState(() {});
      });
  }

  Widget _build(BuildContext context){
    return new DefaultDropdownMenuController(
      onSelected: ({int menuIndex, int index, int subIndex, dynamic data}){
        if(menuIndex == 0){
          SINCE_INDEX = index;
        }else if(menuIndex == 1){
          LANGUAGE_TYPE_INDEX = index;
        }
//        showRefreshLoading();
        _loadFirstData();
      },
      child: new Column(
        children: <Widget>[
          buildDropdownHeader(),
          new Expanded(
              child: new Stack(
                children: <Widget>[
                  new ListView.builder(
                    controller: scrollController,
                    key: refreshIndicatorKey,
                    itemCount: items.length+1,
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
                        TrendingRepoModel item = items[index];
                        return _ListItem(context, item, (){
                          String ownerName = item.name;
                          String repoName = item.reposName;
                          Navigator.push(context, MaterialPageRoute(builder: (context) => RepositoryDetailPage(userName: ownerName, repoName: repoName,)));
                        });
                      }
                    },
                    physics: const AlwaysScrollableScrollPhysics(),
                  ),
                  buildDropdownMenu(),
                ],
              )
          ),
        ],
      ),
    );
  }

  Widget _ListItem(BuildContext context, TrendingRepoModel item, VoidCallback onPressed) {
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
                    new Container(
                      width: 50,
                      height: 50,
                      child: new ClipOval(
                        child: CachedNetworkImage(
                          imageUrl: item.contributors.first,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Image(image: new AssetImage(UIcons.DEFAULT_AVATAR)),
                        ),
                      ),
                    ),
                    new Padding(padding: EdgeInsets.only(left: 10.0)),
                    new Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          new Text(item.reposName, style: new TextStyle(
                            fontSize: 20.0,
                            color: Colors.black87,
                          ), maxLines: 2,),
                          Row(
                            children: <Widget>[
                              Icon(const IconData(0xe63e, fontFamily: Config.FONT_FAMILY), size: 10, color: Colors.grey,),
                              Padding(padding: EdgeInsets.only(left: 5.0)),
                              Text(item.name, style: TextStyle(color: Colors.grey, fontSize: 12),),
                            ],
                          ),
                        ],
                      ),
                    ),
                    new Text(item.language)
                  ],
                ),
                new Container(
                  child: new Text(item.description, style: new TextStyle(
                    color: Colors.black54,
                  ),),
                  margin: new EdgeInsets.only(top: 6.0, bottom: 2.0),
                  alignment: Alignment.topLeft,
                ),
                Padding(padding: EdgeInsets.only(top: 10.0)),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _listItemPictureLabel(context, const IconData(0xe643, fontFamily: Config.FONT_FAMILY), item.starCount),
                    SizedBox(width: 5),
                    _listItemPictureLabel(context, const IconData(0xe67e, fontFamily: Config.FONT_FAMILY), item.forkCount),
                    SizedBox(width: 5),
                    _listItemPictureLabel(context, const IconData(0xe661, fontFamily: Config.FONT_FAMILY), item.meta, flex: 4),
                  ],
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _listItemPictureLabel(BuildContext context, IconData iconData, String text, {int flex = 3}) {
    return new Expanded(
      flex: flex,
      child: new Center(
        child: Row(
          textBaseline: TextBaseline.alphabetic,
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Icon(iconData, size: 15, color: Colors.grey,),
            Padding(padding: EdgeInsets.only(left: 5.0)),
            new Container(
              width: flex == 4
                  ? (MediaQuery.of(context).size.width - 100)/3
                  : (MediaQuery.of(context).size.width-100)/5,
              child: Text(text, style: TextStyle(fontSize: 13, color: Colors.grey), overflow: TextOverflow.ellipsis,),
            )
          ],
        ),
      ),
    );
  }

  DropdownHeader buildDropdownHeader({DropdownMenuHeadTapCallback onTap}) {
    return new DropdownHeader(
      onTap: onTap,
      titles: [SINCE[SINCE_INDEX], LANGUAGE_TYPE[LANGUAGE_TYPE_INDEX]],
    );
  }

  DropdownMenu buildDropdownMenu() {
    return new DropdownMenu(maxMenuHeight: kDropdownMenuItemHeight * 10,
        //  activeIndex: activeIndex,
        menus: [
          new DropdownMenuBuilder(
              builder: (BuildContext context) {
                return new DropdownListMenu(
                  selectedIndex: SINCE_INDEX,
                  data: SINCE,
                  itemBuilder: buildCheckItem,
                  itemExtent: 50,
                );
              },
              height: kDropdownMenuItemHeight * SINCE.length
          ),new DropdownMenuBuilder(
              builder: (BuildContext context) {
                return new DropdownListMenu(
                  selectedIndex: LANGUAGE_TYPE_INDEX,
                  data: LANGUAGE_TYPE,
                  itemBuilder: buildCheckItem,
                );
              },
              height: kDropdownMenuItemHeight * LANGUAGE_TYPE.length
          ),
        ]);
  }

}