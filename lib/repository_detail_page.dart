import 'package:flutter/material.dart';
import 'package:github/common/dao/repository_detail_dao.dart';
import 'package:github/repository_detail_file_page.dart';
import 'package:github/repository_detail_info_page.dart';
import 'package:github/repository_detail_issue_page.dart';
import 'package:github/repository_detail_readme_page.dart';

class RepositoryDetailPage extends StatefulWidget {

  // 用户名
  final String userName;

  // 仓库名
  final String repoName;

  RepositoryDetailPage({Key key, this.userName, this.repoName}) : super(key : key);

  @override
  State<StatefulWidget> createState() => _RepositoryDetailPageState();

}

class _RepositoryDetailPageState extends State<RepositoryDetailPage> with SingleTickerProviderStateMixin {

  final PageController _pageController = PageController();

  List<Widget> _tabViews;

  TabController _tabController ;

  List<Widget> _tabs;

  @override
  void initState() {
    super.initState();
    _tabViews = [
      new RepositoryDetailInfoPage(userName: widget.userName, repoName: widget.repoName,),
      new RepositoryDetailReadmePage(userName: widget.userName, repoName: widget.repoName,),
      new RepositoryDetailIssuePage(userName: widget.userName, repoName: widget.repoName,),
      new RepositoryDetailFilePage(userName: widget.userName, repoName: widget.repoName,),
    ];
    _tabs = [
      _renderTab('动态'),
      _renderTab('详情'),
      _renderTab('ISSUE'),
      _renderTab('文件'),
    ];
    _tabController = new TabController(length: _tabViews.length, vsync: this);
  }

  _renderTab(text) {
    return new Tab(
      child: new Text(text),
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
      resizeToAvoidBottomPadding: true,
      body: new PageView(
        controller: _pageController,
        children: _tabViews,
        onPageChanged: (index) {
          _tabController.animateTo(index);

        },
      ),
      appBar: new AppBar(
        title: Text(widget.repoName),
        bottom: new TabBar(
          controller: _tabController,
          tabs: _tabs,
          onTap: (index) {
            _pageController.jumpTo(MediaQuery.of(context).size.width * index);
          },
        ),
      ),
    );
  }

  Future _loadBranches() async {
    return RepositoryDetailDao.getBranchesDao(widget.userName, widget.repoName).then((data){

    });
  }

}