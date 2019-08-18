import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:github/common/component/ui_component_flex_button_widge.dart';
import 'package:github/common/component/ui_component_input_widget.dart';
import 'package:github/common/config/config.dart';
import 'package:github/common/dao/dao_result.dart';
import 'package:github/common/dao/user_dao.dart';
import 'package:github/common/local/local_storage.dart';
import 'package:github/common/model/user_token.dart';
import 'package:github/common/style/ui_style.dart';
import 'package:github/common/utils/common_utils.dart';
import 'package:github/home_page.dart';

class LoginPage extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {
    return new _LoginPageState();
  }

}


class _LoginPageState extends State<LoginPage> {

  var _username = "";
  var _password = "";

  final TextEditingController usernameController = new TextEditingController();
  final TextEditingController pwdController = new TextEditingController();

  _LoginPageState() : super();

  @override
  void initState() {
    super.initState();
    initParameters();
  }

  initParameters() async{
    _username = await LocalStorage.get(Config.USER_NAME_KEY);
    _password = await LocalStorage.get(Config.PW_KEY);

    usernameController.value = new TextEditingValue(text: _username ?? "");
    pwdController.value = new TextEditingValue(text: _password ?? "");
  }

  _login(){
      if (null == _username || _username.length == 0){
        return;
      }
      if (null == _password || _password.length == 0) {
        return;
      }
      var dialog = CommonUtils.showLoadingDialog(context);
      UserDao.login(_username.trim(), _password.trim()).then((result){
        if(result.status == DataResultStatus.SUCESS){
          UserToken userToken = result.data;
          if (null != userToken){
            Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => HomePage()),(Route<dynamic> route) => false);
          }
        }else{
          Navigator.pop(context, dialog);
          Fluttertoast.showToast(msg: '${result.message}',
              toastLength: Toast.LENGTH_LONG,
          );
        }
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: new GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            FocusScope.of(context).requestFocus(new FocusNode());
          },
          child: new Container(
            color: Colors.deepOrangeAccent,
            child: new Center(
              ///防止overFlow的现象
              child: SafeArea(
                ///同时弹出键盘不遮挡
                child: new SingleChildScrollView(
                  child: new Card(
                    elevation: 5,
                    shape: new RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10.0))),
                    color: Colors.white,
                    margin: const EdgeInsets.only(left:30.0,right: 30.0),
                    child: Padding(
                      padding: new EdgeInsets.only(left: 30.0,top: 40.0,right: 30.0,bottom: 0.0),
                      child: new Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          new Image(image: new AssetImage(UIcons.LOGIN_ICON),width: 90, height: 90),
                          new Padding(padding: new EdgeInsets.all(10.0)),
                          new UIComponentInputWidget(
                            hintText: '请输入用户名',
                            iconData: const IconData(0xe666, fontFamily: Config.FONT_FAMILY),
                            onChanged: (String value) {
                              _username = value;
                            },
                            controller: usernameController,
                          ),
                          new Padding(padding: new EdgeInsets.all(10.0)),
                          new UIComponentInputWidget(
                            hintText: '请输入密码',
                            iconData: const IconData(0xe60e, fontFamily: Config.FONT_FAMILY),
                            onChanged: (String value) {
                              _password = value;
                            },
                            controller: pwdController,
                            obsecureText: true,
                          ),
                          new Padding(padding: new EdgeInsets.all(30.0)),
                          new UIComponentFlexButtonWidget(
                            text: '登录',
                            color: Colors.blue,
                            textColor: Colors.white,
                            onPress: _login,
                          ),
                          new Padding(padding: new EdgeInsets.all(30.0)),
//                    new Text('文本'),
                        ],
                      ),

                    ),
                  ),
                ),
              ),
            ),
          ),
        )
    );
  }

}