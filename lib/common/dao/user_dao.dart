import 'package:github/common/config/config.dart';
import 'dart:convert';
import 'package:github/common/config/ignoreConfig.dart';
import 'package:github/common/net/address.dart';
import 'package:github/common/model/user_token.dart';
import 'package:github/common/local/local_storage.dart';
import 'package:github/common/model/user_entity.dart';
import 'package:github/common/utils/http_utils.dart';
import 'package:github/common/dao/dao_result.dart';

class UserDao {

  static login(String userName, password) async {
    Map requestParams = {
      "scopes": ['user', 'repo', 'gist', 'notifications'],
      "note": "admin_script",
      "client_id": NetConfig.CLIENT_ID,
      "client_secret": NetConfig.CLIENT_SECRET
    };

    String type = userName + ":" + password;
    var bytes = utf8.encode(type);
    var base64Str = base64.encode(bytes);
    if (Config.DEBUG) {
      print("base64Str login " + base64Str);
    }

    Map<String, String> headers = {
      "Authorization": "Basic "+base64Str
    };
    String url = Address.getAuthorization();
    HttpResult response = await HttpUtils.post(url, headers:headers, parameters:requestParams);
    DataResult result;
    switch(response.status){
      case HttpResultStatus.SUCCESS:
        UserToken userToken = UserToken.fromJson(json.decode(response.data));
        LocalStorage.save(Config.USER_NAME_KEY, userName);
        LocalStorage.save(Config.USER_BASIC_CODE, base64Str);
        LocalStorage.save(Config.PW_KEY, password);

        var userResponse = await getUserInfo(userToken.token);
        if(userResponse.status == DataResultStatus.SUCESS){
          result = DataResult(DataResultStatus.SUCESS,data: userToken);
        }else{
          result = userResponse;
        }
        break;
      case HttpResultStatus.TIMEOUT:
        result = DataResult(DataResultStatus.TIMEOUT, code:response.code, message: response.message);
        break;
      case HttpResultStatus.NoNetwork:
        result = DataResult(DataResultStatus.NoNetwork, code:response.code, message: response.message);
        break;
      case HttpResultStatus.FAILURE:
        result = DataResult(DataResultStatus.FAILURE, code:response.code, message: response.message);
        break;
    }

    return result;
  }

  static getUserInfo(String token) async {
    Map<String, String> headers = {
      "Authorization": "token "+token
    };
    var url = Address.getMyUserInfo();

    var response = await HttpUtils.get(url,headers: headers);
    DataResult result;
    switch(response.status) {
      case HttpResultStatus.SUCCESS:
        User userEntity =  User.fromJson(json.decode(response.data));
        await LocalStorage.save(Config.USER_INFO, response.data);
        await LocalStorage.save(Config.TOKEN_KEY, token);
        await LocalStorage.save(Config.LOGIN_KEY, userEntity.login);
        result = DataResult(DataResultStatus.SUCESS,data: userEntity);
        break;
      case HttpResultStatus.TIMEOUT:
        result = DataResult(DataResultStatus.TIMEOUT, code:response.code, message: response.message);
        break;
      case HttpResultStatus.NoNetwork:
        result = DataResult(DataResultStatus.NoNetwork, code:response.code, message: response.message);
        break;
      case HttpResultStatus.FAILURE:
        result = DataResult(DataResultStatus.FAILURE, code:response.code, message: response.message);
        break;
    }

    return result;
  }


}