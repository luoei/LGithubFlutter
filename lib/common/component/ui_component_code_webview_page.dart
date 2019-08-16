import 'package:flutter/material.dart';
import 'package:github/common/component/ui_component_webview_page.dart';
import 'package:github/common/dao/repository_detail_dao.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:github/common/utils/html_utils.dart';
import 'dart:convert';

class UIComponentCodeWebViewPage extends UIComponentWebViewPage {

  // 用户名
  final String userName;

  // 仓库名
  final String repoName;

  // 分支名
  final String branchName;

  final String path;

  final String title;

  UIComponentCodeWebViewPage({Key key,this.userName, this.repoName, this.branchName, this.path, this.title}) : super(key:key);

  @override
  State<StatefulWidget> createState() => _UIComponentCodeWebViewPageState(userName: userName, repoName: repoName, branchName: branchName, path: path,
  title: title);

}

class _UIComponentCodeWebViewPageState extends UIComponentWebViewPageState {

  // 用户名
  final String userName;

  // 仓库名
  final String repoName;

  // 分支名
  final String branchName;

  final String path;

  final String title;

  _UIComponentCodeWebViewPageState({Key key, this.userName, this.repoName, this.branchName,this.path, this.title});

  @override
  void initState() {
    super.initState();

    super.title = title;

    _loadData();
  }

  _loadData(){
    RepositoryDetailDao.getReposFileDirDao(userName, repoName,path: path,isHtml: true).then((data){
        if(data == null){
          return;
        }
        String codeData = HtmlUtils.resolveHtmlFile(data, "java");
        String uri = new Uri.dataFromString(codeData, mimeType: 'text/html', encoding: Encoding.getByName('UTF-8')).toString();
        setState(() {
          this.uri = uri;
        });
    });
  }

  @override
  Widget build(BuildContext context) {

    if (this.uri == null){
      return Scaffold(
        appBar: AppBar(title: Text(title),),
        body: Center(
          child: Container(
            width: 200,
            height: 200,
            padding: EdgeInsets.all(4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SpinKitDoubleBounce(color: Colors.black12,),
                Container(width: 10.0,),
                Container(
                  child: Text('loading...', style: TextStyle(color: Colors.black87,fontSize: 20.0),),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return super.build(context);

  }
}