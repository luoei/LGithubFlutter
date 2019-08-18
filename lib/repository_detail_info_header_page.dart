import 'package:flutter/material.dart';
import 'package:github/common/config/config.dart';
import 'package:github/common/model/Repository.dart';

class RepositoryDetailInfoHeaderPage extends StatefulWidget {
  // 用户名
  final ValueChanged<Size> layoutListener;

  final Repository repository;

  RepositoryDetailInfoHeaderPage({Key key, this.layoutListener, this.repository}) : super(key : key);

  @override
  State<StatefulWidget> createState() => _RepositoryDetailInfoHeaderPageState();
}

class _RepositoryDetailInfoHeaderPageState extends State<RepositoryDetailInfoHeaderPage> {

  final GlobalKey layoutKey = new GlobalKey();

  double widgetHeight = 0;

  @override
  void didUpdateWidget(RepositoryDetailInfoHeaderPage oldWidget) {
    super.didUpdateWidget(oldWidget);

    new Future.delayed(Duration(seconds: 0), (){
      var height = layoutKey.currentContext.size.height;
      if( height>0 && widgetHeight != height){
        widgetHeight = height;
        if(Config.DEBUG){
          print('Repository Size Height: $height');
        }
        widget?.layoutListener?.call(layoutKey.currentContext.size);
      }
    });

  }

  @override
  Widget build(BuildContext context) {
    return Container(
      key: layoutKey,
      padding: EdgeInsets.only(top: 10.0,left: 5.0, right: 5.0, bottom: 5.0),
      child: Card(
        color: Colors.blue,
        child: Padding(
          padding: EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Text(widget.repository.owner.login, style: TextStyle(color: Colors.red),),
                  Text(' / ${widget.repository.name}' ,style: TextStyle(color: Colors.white),)
                ],
              ),
              Padding(padding: EdgeInsets.only(top: 10.0)),
              Text('${widget.repository.language} ${widget.repository.repositorySize} ${widget.repository.license != null ? (widget.repository.license.name ?? "") : ""}', style: TextStyle(color: Colors.white70),),
              Padding(padding: EdgeInsets.only(top: 10.0)),
              Text(widget.repository.description, maxLines: 1, style: TextStyle(color: Colors.white70),),
              Padding(padding: EdgeInsets.only(top: 10.0)),
              Container(alignment: Alignment.topRight,child: Text('创建于 ${widget.repository.createdAtString}', style: TextStyle(color: Colors.white70),),),
              Padding(padding: EdgeInsets.only(top: 10.0)),
              Container(alignment: Alignment.topRight,child: Text('最后提交于 ${widget.repository.pushedAtString}', style: TextStyle(color: Colors.white70),),),
              Divider(color: Colors.black12),
              Padding(padding: EdgeInsets.only(top: 0.0)),
              Padding(
                padding: EdgeInsets.all(0.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    _listItemPictureLabel(context,const IconData(0xe643, fontFamily: Config.FONT_FAMILY), (widget.repository.stargazersCount ?? 0).toString()),
                    new Container(width: 0.3, height: 25.0, color: Colors.black12),
                    _listItemPictureLabel(context,const IconData(0xe67e, fontFamily: Config.FONT_FAMILY), (widget.repository.forksCount ?? 0).toString()),
                    new Container(width: 0.3, height: 25.0, color: Colors.black12),
                    _listItemPictureLabel(context,const IconData(0xe681, fontFamily: Config.FONT_FAMILY), (widget.repository.subscribersCount ?? 0).toString()),
                    new Container(width: 0.3, height: 25.0, color: Colors.black12),
                    _listItemPictureLabel(context,const IconData(0xe661, fontFamily: Config.FONT_FAMILY), widget.repository.hasIssues ? (widget.repository.openIssuesCount ?? 0).toString() : "---"),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget _listItemPictureLabel(BuildContext context, IconData iconData, String text) {
    double width = (MediaQuery.of(context).size.width-40)/4.2;
    return Expanded(
      child: Container(
        width: width,
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(iconData, size: 15, color: Colors.white70,),
              Padding(padding: EdgeInsets.only(left: 5.0)),
              new Container(
//              color: Colors.deepOrange,
//              width: width*0.4,
                child: Text(text, style: TextStyle(fontSize: 13, color: Colors.white70), overflow: TextOverflow.ellipsis,),
              )
            ],
          ),
        ),
      ),
    );
  }

}


