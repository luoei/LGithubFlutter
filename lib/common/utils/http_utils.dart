import 'package:github/common/utils/http_route_utils.dart';
import 'package:github/common/dao/dao_result.dart';
import 'dart:convert';
import 'package:github/common/local/local_storage.dart';
import 'package:github/common/config/config.dart';

class HttpUtils {

  static Future<HttpResult> _create(String url, String method,{ Map<String, String> headers,  Map parameters}) async {
    Map<String, String> _headers = {};
    if (null != headers){
      _headers = headers;
    }
    if (!_headers.containsKey('Authorization')){
      String token = await LocalStorage.get(Config.TOKEN_KEY);
      if(null != token && token.length > 0){
        _headers['Authorization'] = "token "+token;
      }
    }
    Map response;
    if (method == 'POST'){
      response = await HttpRouteUtils.post(url, _headers, parameters);
    }else{
      response = await HttpRouteUtils.get(url, _headers);
    }
    HttpResult result;
    int code = response['code'] as int;
    if (code == 200 || code == 201){
      result = HttpResult(HttpResultStatus.SUCCESS, data: response['data']);
    }else if (response['code'] == -201){
      result = HttpResult(HttpResultStatus.TIMEOUT, message: "连接超时，请稍后再试");
    }else if (response['code'] == 7){
      result = HttpResult(HttpResultStatus.NoNetwork, message: "无网络");
    }else{
      if( null != response && null != response['data']){
        result = HttpResult(HttpResultStatus.FAILURE, message: (json.decode(response['data']) as Map)['message']);
      }else{
        result = HttpResult(HttpResultStatus.FAILURE, message: "服务器累了，请稍后再试");
      }
    }
    return result;
  }

  static Future<HttpResult> post(String url, {Map<String, String> headers,  Map parameters}) async {
      return _create(url, 'POST',headers: headers,parameters: parameters);
   }

  static Future<HttpResult> get(String url, {Map<String, String> headers}) async {
    return _create(url, 'GET',headers: headers);
  }

}
