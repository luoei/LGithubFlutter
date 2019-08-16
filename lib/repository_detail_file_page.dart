import 'package:flutter/material.dart';
import 'package:github/common/config/config.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:github/common/dao/repository_detail_dao.dart';
import 'package:github/common/utils/navigator_utils.dart';
import 'package:github/common/utils/common_utils.dart';
import 'dart:math' as math;
import 'package:github/common/model/FileModel.dart';
import 'package:github/common/component/ui_component_code_webview_page.dart';

typedef void SelectedItemChanged<FileModel>(FileModel value);

class RepositoryDetailFilePage extends StatefulWidget {
  // 用户名
  final String userName;

  // 仓库名
  final String repoName;

  // 分支名
  final String branchName;

  RepositoryDetailFilePage({Key key, this.userName, this.repoName, this.branchName}) : super(key : key);

  @override
  State<StatefulWidget> createState() => _RepositoryDetailFilePageState();
}

class _RepositoryDetailFilePageState extends State<RepositoryDetailFilePage>
    with AutomaticKeepAliveClientMixin<RepositoryDetailFilePage> {

  bool isRefreshing = false;

  bool isLoadingMore = false;

  final GlobalKey<RefreshIndicatorState> refreshIndicatorKey =new GlobalKey<RefreshIndicatorState>();

  ScrollController scrollController = new ScrollController();

  String _currentBranch = "master";

  String _path = '';

  List<String> headerList = ['.'];

  List dataSource;

  @override
  void initState() {
    super.initState();

    _loadData();
  }

  @override
  bool get wantKeepAlive => true;


  Future _loadData() async{
    return RepositoryDetailDao.getReposFileDirDao(widget.userName, widget.repoName, path: _path, branch: _currentBranch).then((data) {
      if (null != data) {
        setState(() {
          this.dataSource = data;
        });
      }
    });
  }

  showRefreshLoading() {
    new Future.delayed(const Duration(seconds: 0), () {
      refreshIndicatorKey.currentState.show().then((e) {});
      return true;
    });
  }

  _renderHeader() {
    return Container(
      margin: EdgeInsets.only(left: 3.0, right: 3.0),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index){
          return RawMaterialButton(
            constraints: BoxConstraints(minWidth: 0, minHeight: 0),
            padding: EdgeInsets.all(4.0),
            onPressed: (){
              _resolveHeaderClick(index);
            },
            child: Text(headerList[index] +" > ", style: TextStyle(color: Colors.grey, fontSize: 15),),
          );
        },
        itemCount: headerList.length,
      ),
    );
  }

  _itemDidClick(FileModel item) {
    if (item.type == 'dir') {
      setState(() {
        headerList.add(item.name);
        _path = headerList.sublist(1, headerList.length).join("/");
      });
//      showRefreshLoading();
    _loadData();
    }else{
      String path = headerList.sublist(1, headerList.length).join("/") +"/"+item.name;
      if (CommonUtils.isImageEnd(path)){
          NavigatorUtils.gotoPhotoViewPage(context, item.htmlUrl +"?raw=true");
      }else{
        NavigatorUtils.NavigatorRouter(context, new UIComponentCodeWebViewPage(userName: widget.userName, repoName: widget.repoName, branchName: _currentBranch, path: path,title: item.name,));
      }
    }
  }

  _resolveHeaderClick(index){
    if (headerList[index] != "."){
      List<String> newHeaderList = headerList.sublist(0,index+1);
      String path = newHeaderList.sublist(1, newHeaderList.length).join("/");
      setState(() {
        _path = path;
        headerList = newHeaderList;
      });
      _loadData();
    }else{
      setState(() {
        _path = "";
        headerList = ["."];
      });
      _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    var resultView = (dataSource == null
        ? SpinKitThreeBounce(
      color: Colors.black54,
      size: 30,
    )
        : _build(context));
    return resultView;
  }

  Widget _build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: _renderHeader(),
        backgroundColor: Colors.white,
        leading: Container(),
        elevation: 0,
      ),
      body: RefreshIndicator(
        child: ListView.builder(
          controller: scrollController,
          key: refreshIndicatorKey,
          itemCount: null == dataSource ? 0 : dataSource.length,
          itemBuilder: (context, index) {
            return _ListItem(context, dataSource[index], (item){
              _itemDidClick(item);
            });
          },
          physics: const AlwaysScrollableScrollPhysics(),
        ),
        onRefresh:_loadData,
      ),
    );
  }

  Widget _ListItem(BuildContext context, FileModel item, SelectedItemChanged onPressed) {
    IconData iconData = (item.type == "file") ? const IconData(0xea77, fontFamily: Config.FONT_FAMILY) : Icons.folder;
    Widget trailing = (item.type == "file") ? null : new Icon(const IconData(0xe610, fontFamily: Config.FONT_FAMILY), size: 12.0);
    return new Container(
      child: new Card(
        elevation: 5.0,
        margin: EdgeInsets.all(10.0),
        shape: new RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(4.0))),
        color: Colors.white,
        child: new ListTile(
          title: new Text(item.name),
          leading: new Icon(
            iconData,
            size: 16.0,
          ),
          onTap: () {
            onPressed(item);
          },
          trailing: trailing,
        ),
      ),
    );
  }

}
