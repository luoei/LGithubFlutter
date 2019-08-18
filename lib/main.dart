import 'package:flutter/material.dart';
import 'package:github/common/config/config.dart';
import 'package:github/common/local/local_storage.dart';
import 'package:github/home_page.dart';
import 'package:github/login_page.dart';

void main() {
  LocalStorage.get(Config.TOKEN_KEY).then((res){
    if (res !=null ){
      runApp(MaterialApp(
        home: HomePage(),
      ));
    }else{
      runApp(MaterialApp(
        home: LoginPage(),
      ));
    }
  });

}




