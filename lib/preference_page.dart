import 'package:flutter/material.dart';
import 'package:github/common/config/config.dart';
import 'package:github/common/local/local_storage.dart';
import 'package:github/common/style/ui_style.dart';
import 'package:github/common/utils/navigator_utils.dart';
import 'package:github/login_page.dart';
import 'package:package_info/package_info.dart';

class PreferencePage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('设置'),
      ),
      body: ListView(
        children: <Widget>[
          Padding(padding: EdgeInsets.only(top: 15.0),),
          new Container(
            decoration: new BoxDecoration(
              border: new Border.all(color: Colors.grey[200]),
            ),
            child: ListTile(
              leading: Icon(Icons.info),
              title: Text('关于'),
              onTap: (){
                PackageInfo.fromPlatform().then((value) {
                  print(value);
                  showAboutDialog(context, value);
                });
              },
            ),
          ),
          Padding(padding: EdgeInsets.only(top: 15.0),),
          new Container(
            height: 50.0,
            child: Padding(
              padding: EdgeInsets.only(left: 30, right: 30),
              child: new Card(
                margin: EdgeInsets.all(0),
                shape: new RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(5.0))),
                color: Colors.deepOrange,
                child: FlatButton(
                    onPressed: (){
                      LocalStorage.remove(Config.TOKEN_KEY);
                      Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => LoginPage()),(Route<dynamic> route) => false);
                    },
                    child: Text('注 销', style: TextStyle(fontSize: 20, color: Colors.white)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  showAboutDialog(BuildContext context, PackageInfo packageInfo) {
    NavigatorUtils.showDialogView(
        context: context,
        builder: (BuildContext context) => AboutDialog(
          applicationName: packageInfo.appName,
          applicationVersion: '版本：${packageInfo.version}',
          applicationIcon: new Image(image: new AssetImage(UIcons.LOGIN_ICON), width: 50.0, height: 50.0),
          applicationLegalese: "https://github.com/luoei",
        ));
  }

}