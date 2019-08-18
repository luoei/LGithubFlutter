import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:github/common/config/config.dart';
import 'package:http/http.dart' as http;

class HttpRouteUtils {

  static Future<Map> _create(String url,String method,{Map<String, String> headers,  Map parameters}) async {
    if(Config.DEBUG){
      print('\n--------------------------\n[$method][请求]URL：$url \nHeader：${headers.toString()} \n参数：${json.encode(parameters)}\n--------------------------\n');
    }
    try{
      var response;
      if (method == 'POST'){
         response = await http.post(url,headers: headers,body: json.encode(parameters)).timeout(Duration(seconds: 30));
      }else{
        response = await http.get(url, headers: headers).timeout(Duration(seconds: 30));
      }
      String body = response.body;
      if (Config.DEBUG) {
        print('\n--------------------------\n[$method][返回]URL：$url \nStatus：${response.statusCode} \n数据：$body\n--------------------------\n');
      }
      return {"code":response.statusCode, "data": body};
    }on TimeoutException catch(e){
      if (Config.DEBUG) {
        print('\n--------------------------\n[$method][返回]URL：$url \n异常：${e.message}\n--------------------------\n');
      }
      return {"code":-201, "message": e.message};
    }on SocketException catch(e){
      if (Config.DEBUG) {
        print('\n--------------------------\n[$method][返回]URL：$url \n异常：${e.message}\n--------------------------\n');
      }
      if(e.osError != null){
        return {"code":e.osError.errorCode, "message":  e.osError.message};
      }else{
        return {"code":-200, "message":  e.message};
      }
    }catch(e){
      if (Config.DEBUG) {
        print('\n--------------------------\n[$method][返回]URL：$url \n异常：${e}\n--------------------------\n');
      }
      return {"code":-100, "message": e};
    }
  }

  static Future<Map> post(String url,Map<String, String> headers,  Map parameters) async {
      return _create(url, 'POST', headers: headers, parameters: parameters);
   }

  static Future<Map> get(String url,Map<String, String> headers) async {
   return _create(url, 'GET', headers: headers);
  }

}
