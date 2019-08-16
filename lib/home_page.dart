import 'package:flutter/material.dart';
import 'package:github/dynamic_page.dart';
import 'package:github/trend_page.dart';
import 'package:github/my_page.dart';

class HomePage extends StatefulWidget {

  static final String sName = 'home';


  @override
  State<StatefulWidget> createState() {
    return new _HomePageState();
  }


}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {

  final PageController _pageController = PageController();

  List<Widget> _tabViews;

  TabController _tabController ;

  List<Widget> _tabs;

  @override
  void initState() {
    super.initState();
    _tabViews = [
      new DynamicPage(),
      new TrendPage(),
      new MyPage(),
    ];
    _tabs = [
      _renderTab(const IconData(0xe684, fontFamily: 'wxcIconFont'),'动态'),
      _renderTab(const IconData(0xe818, fontFamily: 'wxcIconFont'),'趋势'),
      _renderTab(const IconData(0xe6d0, fontFamily: 'wxcIconFont'),'我的'),
    ];
    _tabController = new TabController(length: _tabViews.length, vsync: this);
  }

  _renderTab(icon, text) {
    return new Tab(
      child: new Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[new Icon(icon, size: 16.0), new Text(text)],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {

    return Scaffold(
      
      body: new PageView(
        controller: _pageController,
        children: _tabViews,
        onPageChanged: (index) {
          _tabController.animateTo(index);

        },
      ),
      bottomNavigationBar: new Material(
        color: Colors.blue,
        child: new SafeArea(
          child: new TabBar(
            controller: _tabController,
            tabs: _tabs,
            onTap: (index) {
              _pageController.jumpTo(MediaQuery.of(context).size.width * index);
            },
          ),
        ),
      ),
      
    );
  }
  
}