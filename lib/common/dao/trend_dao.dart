import 'package:github/common/config/config.dart';
import 'package:github/common/net/address.dart';
import 'package:http/http.dart' as http;
import 'package:github/common/local/local_storage.dart';
import 'package:github/common/utils/trending_utils.dart';

class TrendDao {

  static Future<http.Response> fetchGet(String url,Map<String, String> header) async {
    return await http.get(url,headers: header);
  }


  static getTrend({since = 'daily', languageType, page = 0}) async {

    String token = await LocalStorage.get(Config.TOKEN_KEY);
    Map<String, String> headers = {
      "Authorization": "token "+token
    };

    String userName = await LocalStorage.get(Config.LOGIN_KEY);
    var url = Address.trending(since, languageType);
    if(Config.DEBUG){
      print('请求URL：'+url);
      print('请求Header：'+headers.toString());
    }
    var response = await fetchGet(url,headers);
    int status = response.statusCode;
    String body = response.body;
    if (Config.DEBUG) {
      print('返回数据: ${response.statusCode} - ${response.body}');
    }
    if (status == 200 || status == 201 ) {
      return TrendingUtil.htmlToRepo(body);
    }else{
      return null;
    }

  }


}