import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:github/common/style/ui_style.dart';
import 'package:photo_view/photo_view.dart';

class UIComponentPhotoViewPage extends StatelessWidget {

  final String url;

  UIComponentPhotoViewPage(this.url);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(""),
      ),
      body: Container(
        color: Colors.black,
        child: new PhotoView(
          imageProvider:new NetworkImage(url ?? UIcons.DEFAULT_REMOTE_PIC),
          loadingChild: Container(
            child: new Stack(
              children: <Widget>[
                new Center(child: new Image.asset(UIcons.DEFAULT_IMAGE, height: 180.0, width: 180.0,),),
                new Center(child: new SpinKitFoldingCube(color: Colors.white30, size: 60.0,),),
              ],
            ),
          ),
        ),
      ),
    );
  }


}


