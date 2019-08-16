import 'package:flutter/material.dart';
import 'package:github/common/config/config.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:github/common/dao/repository_detail_dao.dart';
import 'package:github/common/model/Repository.dart';
import 'package:github/common/model/Event.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:github/common/style/ui_style.dart';
import 'package:github/common/utils/common_utils.dart';
import 'package:github/repository_detail_info_header_page.dart';
import 'package:github/repository_detail_info_segement_page.dart';
import 'dart:math' as math;
import 'package:github/common/model/RepoCommit.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class RepositoryDetailReadmePage extends StatefulWidget {
  // 用户名
  final String userName;

  // 仓库名
  final String repoName;

  // 分支名
  final String branchName;

  RepositoryDetailReadmePage({Key key, this.userName, this.repoName, this.branchName}) : super(key : key);

  @override
  State<StatefulWidget> createState() => _RepositoryDetailReadmePageState();
}

class _RepositoryDetailReadmePageState extends State<RepositoryDetailReadmePage>
    with AutomaticKeepAliveClientMixin<RepositoryDetailReadmePage> {

  String _currentBranch = "master";

  String data;

  @override
  void initState() {
    super.initState();

    _loadData();

  }

  @override
  bool get wantKeepAlive => true;


  Future _loadData() async{
    return RepositoryDetailDao.getRepositoryDetailReadmeDao(widget.userName, widget.repoName,branch: _currentBranch).then((data) {
      if (null != data) {
        setState(() {
          this.data = data;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var resultView = (data == null
        ? SpinKitThreeBounce(
      color: Colors.black54,
      size: 30,
    )
        : _bodyView(context));
    return resultView;
  }

  Widget _bodyView(BuildContext context){
    return  Markdown(data: data,);
  }

}
