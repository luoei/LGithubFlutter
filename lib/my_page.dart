import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:github/common/model/user_entity.dart';
import 'package:github/common/local/local_storage.dart';
import 'package:github/common/config/config.dart';
import 'dart:convert';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:github/common/utils/common_utils.dart';
import 'package:github/common/dao/my_dao.dart';
import 'package:github/common/model/Event.dart';
import 'package:github/common/dao/user_dao.dart';
import 'package:github/common/component/ui_component_webview_page.dart';
import 'package:github/preference_page.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:github/common/style/ui_style.dart';
import 'package:github/repository_detail_page.dart';

class MyPage extends StatefulWidget {

  @override
  State<StatefulWidget> createState() => _MyPageState();

}

class _MyPageState extends State<MyPage> with AutomaticKeepAliveClientMixin<MyPage> {
  bool isRefreshing = false;
  bool isLoadingMore = false;
  final GlobalKey<RefreshIndicatorState> refreshMyPageIndicatorKey = new GlobalKey<RefreshIndicatorState>();
  ScrollController scrollController = new ScrollController();
  var _pageNo = 1;
  List<Event> dataSource;
  User user;
  int _starCount = 0;
  int _beStaredCount = 0;

  @override
  void initState() {
    super.initState();

    _loadUserInfoData();
    _loadFirstData();
    _loadUserStarData();
    _loadUserBestaredData();
//    scrollController.addListener(_updateScrollPosition);
  }

  @override
  void dispose() {
//    scrollController.removeListener(_updateScrollPosition);
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;

  void _updateScrollPosition() {
    double offsetPixels = scrollController.position.pixels;
    bool isBottom = offsetPixels ==
        scrollController.position.maxScrollExtent;
    if (!isLoadingMore && isBottom && !isRefreshing) {
      setState(() {
        _loadMoreData();
      });
    }
//    print('ScrollView offset: ${offsetPixels}');
  }

  _loadUserInfoData() async {
    var userinfo = await LocalStorage.get(Config.USER_INFO);
    if (userinfo != null) {
      user = User.fromJson(json.decode(userinfo));
      setState(() {});
    }
    var token = await LocalStorage.get(Config.TOKEN_KEY);
    if (token != null) {
      UserDao.getUserInfo(token).then((data) {
        user = data;
        setState(() {});
      });
    }

  }

  _loadUserStarData() async {
    MyDao.starCount().then((data) {
      _starCount = data;
      setState(() {});
    });
  }

  _loadUserBestaredData() async {
    MyDao.userRepository100StatusCount().then((data) {
      _beStaredCount = data;
      setState(() {});
    });
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
    return MyDao.events(pageNo).then((data){
      if (pageNo < 2 || dataSource == null || dataSource.length == 0){
        dataSource = data;
      }else{
        if ((data as List).length > 0){
          _pageNo = pageNo;
          dataSource.addAll(data);
        }
      }
      isRefreshing = false;
      isLoadingMore = false;
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    var resultView = (dataSource == null ? SpinKitThreeBounce(color: Colors.black54, size: 30,) : _bodyView(context));
    return Scaffold(
      body: RefreshIndicator(
        child: resultView,
        onRefresh: _loadFirstData,
      ),
    );
  }

  Widget _bodyView(BuildContext context) {
    return CustomScrollView(
      controller: scrollController,
      slivers: <Widget>[
        SliverPersistentHeader(
          pinned: true,
          delegate: SliverMyPageHeaderDelegate(
              title: user.name ?? '',
              collapsedHeight: 56,
              expandedHeight: 200,
              paddingTop: MediaQuery.of(context).padding.top,
              coverImgUrl: user.avatarUrl
          ),
        ),
        SliverPersistentHeader(
          pinned: true,
          delegate: StickySliverPersistentDelegate(
            user: user,
            beStaredCount: _beStaredCount,
            starCount: _starCount,
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate((context, index) => _listItem(context, index),
            childCount: (dataSource != null ? dataSource.length : 0),// ListTile(title: Text('Item #$index');
          ),
        ),
      ],
    );
  }

  Widget _headerSliver(BuildContext context) {
    return FlexibleSpaceBar(
      title: Text(user.name ?? ""),
      background: Image.network(user.avatarUrl, fit: BoxFit.cover,),
    );
  }

  Widget _listItem(BuildContext context,int index) {
      if (index == 0){
        return _header(context);
      }else if(index == dataSource.length){
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
        Event item = dataSource[index];
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
  }

  Widget _ListItem(BuildContext context, Event item, VoidCallback onPressed) {
    return new Container(
      child: new Card(
        elevation: 3.0,
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
                        imageUrl: user.avatarUrl,
                        width: 30,
                        height: 30,
                        placeholder: (context, url) => Image(image: new AssetImage(UIcons.DEFAULT_AVATAR), width: 30, height: 30,),
                      ),
                    ),
                    new Padding(padding: EdgeInsets.only(left: 10.0)),
                    new Expanded(child: new Text(item.actor.login, style: new TextStyle(
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

  Widget _header(BuildContext context) {
//    Color backgroundColor = Color.fromRGBO(42,150,240,1);
    Color backgroundColor = Color.fromARGB(0, 0, 0, 0);
    return new Container(
      child: new Column(
        children: <Widget>[
          new Container(
            color: backgroundColor,
            child: new Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                new Padding(padding: EdgeInsets.only(top: 10.0)),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    new Container(
                      padding: EdgeInsets.only(top: 10.0,left: 10.0, right: 10.0),
                      child: new ClipOval(
                        child: CachedNetworkImage(
                          imageUrl: user.avatarUrl,
                          width: 60,
                          height: 60,
                          placeholder: (context, url) => Image(image: new AssetImage(UIcons.DEFAULT_AVATAR), width: 60, height: 60,),
                        ),
                      ),
                    ),
                    new Padding(padding: EdgeInsets.all(5.0)),
                    new Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(user.login , style: new TextStyle(
                          fontSize: 24,
                        ),),
//                        Text(user.email),
//                        new Padding(padding: EdgeInsets.only(top: 10.0)),
                        new Row(
                          children: <Widget>[
                            Icon(Icons.email, size: 10,),
                            new Padding(padding: EdgeInsets.only(left: 5.0)),
                            Text(user.email ?? '目前什么也没有' , style: new TextStyle(fontSize: 10.0,color: Colors.black87),)
                          ],
                        ),
                        new Padding(padding: EdgeInsets.only(top: 3.0)),
                        new Row(
                          children: <Widget>[
                            Icon(const IconData(0xe63e, fontFamily: Config.FONT_FAMILY), size: 10,),
                            new Padding(padding: EdgeInsets.only(left: 5.0)),
                            Text(user.company ?? '目前什么也没有' , style: new TextStyle(fontSize: 10.0,color: Colors.black87),)
                          ],
                        ),
                        new Padding(padding: EdgeInsets.only(top: 3.0)),
                        new Row(
                          children: <Widget>[
                            Icon(const IconData(0xe7e6, fontFamily: Config.FONT_FAMILY), size: 10,),
                            new Padding(padding: EdgeInsets.only(left: 5.0)),
                            Text(user.location ?? '目前什么也没有' , style: new TextStyle(fontSize: 10.0,color: Colors.black87),)
                          ],
                        ),
                      ],
                    ),
//                new Padding(padding: EdgeInsets.only(bottom: 10.0))
                  ],

                ),
                new Container(
                  padding: EdgeInsets.only(left: 10.0),
                  child: _button(context, const IconData(0xe670, fontFamily: Config.FONT_FAMILY), Text( user.htmlUrl ?? '', style: new TextStyle(fontSize: 12.0, color: Colors.blue)), (){
                    if (user.htmlUrl != null && user.htmlUrl.length > 0){
                      Navigator.push(context, MaterialPageRoute(builder: (context) => new UIComponentWebViewPage(uri: user.htmlUrl,)));
                    }
                  }),
                ),
                new Container(
                  padding: EdgeInsets.only(left: 10.0, right: 10.0),
                  child: Text(user.bio ?? '', maxLines: 3,),
                ),
                new Padding(padding: EdgeInsets.only(top: 10.0)),
                new Container(
                  padding: EdgeInsets.only(left: 10.0),
                  child: Text('创建于: ${CommonUtils.timeString(user.createdAt, 'yyyy年MM月dd日')}', style: new TextStyle(fontSize: 12.0),),
                ),
                new Padding(padding: EdgeInsets.only(top: 10.0)),
              ],
            ),
          ),
//          _headerBottomView(context),
        ],
      ),
    );
  }


  Widget _button(BuildContext context, IconData iconData, Text text, VoidCallback onPress) {
    return new FlatButton(
              padding: EdgeInsets.all(0),
              onPressed: onPress,
              child: new Row(
                  children: <Widget>[
                    Icon(iconData, size:10),
                    new Padding(padding: EdgeInsets.only(left: 5.0)),
                    text,
                  ],
              ),
        );
  }

}

class StickySliverPersistentDelegate extends SliverPersistentHeaderDelegate  {

  final User user;

  final int starCount;

  final int beStaredCount;

  StickySliverPersistentDelegate({@required this.user, this.starCount = 0, this.beStaredCount = 0});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    var radis = Radius.circular(10);
    Color separatorColor = Colors.grey;
    Color backgroundColor = Colors.white;
    return new Card(
      color: backgroundColor,
      margin: EdgeInsets.all(0),
      shape: new RoundedRectangleBorder(
        borderRadius: BorderRadius.only(bottomLeft: radis, bottomRight: radis),
      ),
      child: new Container(
        alignment: Alignment.center,
        child: new Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            _headerBottomViewButton(context, '仓库', user.publicRepos),
            new Container(
                width: 0.3,
                height: 40.0,
                alignment: Alignment.center,
                color: separatorColor),
            _headerBottomViewButton(context, '粉丝', user.followers),
            new Container(
                width: 0.3,
                height: 40.0,
                alignment: Alignment.center,
                color: separatorColor),
            _headerBottomViewButton(context, '关注', user.following),
            new Container(
                width: 0.3,
                height: 40.0,
                alignment: Alignment.center,
                color: separatorColor),
            _headerBottomViewButton(context, '星标', starCount),
            new Container(
                width: 0.3,
                height: 40.0,
                alignment: Alignment.center,
                color: separatorColor),
            _headerBottomViewButton(context, '荣耀', beStaredCount),
          ],
        ),
      ),
    );
  }

  Widget _headerBottomViewButton(BuildContext context, String title, int desc) {
    TextStyle textStyle = new TextStyle(color: Colors.black87, fontSize: 12);
    return new Expanded(
      child: new Center(
        child: new RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            children: [
              TextSpan(text: title, style: textStyle),
              TextSpan(text: "\n", style: textStyle),
              TextSpan(text: desc.toString(), style: textStyle),
            ],
          ),
        ),
      ),
    );
  }

  @override
  double get maxExtent => 50;

  @override
  double get minExtent => 50;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}

class SliverMyPageHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double collapsedHeight;
  final double expandedHeight;
  final double paddingTop;
  final String coverImgUrl;
  final String title;
  String statusBarMode = 'dark';

  SliverMyPageHeaderDelegate({
    this.collapsedHeight,
    this.expandedHeight,
    this.paddingTop,
    this.coverImgUrl,
    this.title,
  });

  @override
  double get minExtent => this.collapsedHeight + this.paddingTop;

  @override
  double get maxExtent => this.expandedHeight;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }

  void updateStatusBarBrightness(shrinkOffset) {
    if(shrinkOffset > 50 && this.statusBarMode == 'light') {
      this.statusBarMode = 'dark';
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarBrightness: Brightness.dark,
        statusBarIconBrightness: Brightness.dark,
      ));
    } else if(shrinkOffset <= 50 && this.statusBarMode == 'dark') {
      this.statusBarMode = 'light';
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarBrightness: Brightness.light,
        statusBarIconBrightness: Brightness.light,
      ));
    }
  }

  Color makeStickyHeaderBgColor(shrinkOffset) {
    final int alpha = (shrinkOffset / (this.maxExtent - this.minExtent) * 255).clamp(0, 255).toInt();
//    return Color.fromARGB(alpha, 255, 255, 255);
    return Color.fromARGB(alpha, 0, 152, 240);
  }

  Color makeStickyHeaderTextColor(shrinkOffset, isIcon) {
    if(shrinkOffset <= 50) {
      return isIcon ? Colors.black :  Colors.transparent;
    } else {
      final int alpha = (shrinkOffset / (this.maxExtent - this.minExtent) * 255).clamp(0, 255).toInt();
      return Color.fromARGB(alpha, 255, 255, 255);
    }
  }

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    this.updateStatusBarBrightness(shrinkOffset);
    return Container(
      height: this.maxExtent,
      width: MediaQuery.of(context).size.width,
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Container(
            child:CachedNetworkImage(
              imageUrl: coverImgUrl,
              fit: BoxFit.cover,
              placeholder: (context, url) => Image(image: new AssetImage(UIcons.DEFAULT_IMAGE)),
            ),
          ),
          Positioned(
            left: 0,
            top: this.maxExtent / 2,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0x00000000),
                    Color(0x90000000),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            child: Container(
              color: this.makeStickyHeaderBgColor(shrinkOffset),
              child: SafeArea(
                bottom: false,
                child: Container(
                  height: this.collapsedHeight,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      IconButton(
                        icon: Icon(
                          Icons.arrow_back_ios,
                          color: Color.fromARGB(0, 0, 0, 0),
//                          color: this.makeStickyHeaderTextColor(shrinkOffset, true),
                        ),
//                        onPressed: () => Navigator.pop(context),
                      ),
                      Text(
                        this.title,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          color: this.makeStickyHeaderTextColor(shrinkOffset, false),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.menu,
                          color: this.makeStickyHeaderTextColor(shrinkOffset, true),
                        ),
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => PreferencePage()));
//                          Navigator.push(context, MaterialPageRoute(builder: (context) => TrendPage1()));
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}