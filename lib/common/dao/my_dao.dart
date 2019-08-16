import 'package:github/common/config/config.dart';
import 'package:github/common/net/address.dart';
import 'package:http/http.dart' as http;
import 'package:github/common/local/local_storage.dart';
import 'package:github/common/model/Event.dart';
import 'dart:convert';
import 'package:github/common/model/Repository.dart';

class MyDao {

  static Future<http.Response> fetchGet(String url,Map<String, String> header) async {
    return await http.get(url,headers: header);
  }


  static events(int page) async {

    String token = await LocalStorage.get(Config.TOKEN_KEY);
    Map<String, String> headers = {
      "Authorization": "token "+token
    };

    String userName = await LocalStorage.get(Config.LOGIN_KEY);
    var url = Address.getEvent(userName) + Address.getPageParams("?", page);
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
      List<Event> list = (json.decode(body) as List).map((e) {
        Event event = Event.fromJson(e);
        event.generator();
        return event;
      })?.toList();
      return list;
    }

  }

  static starCount() async {

    String token = await LocalStorage.get(Config.TOKEN_KEY);
    Map<String, String> headers = {
      "Authorization": "token "+token
    };

    String userName = await LocalStorage.get(Config.LOGIN_KEY);
    var url = Address.userStar(userName, null) + "&per_page=1";
    if(Config.DEBUG){
      print('请求URL：'+url);
      print('请求Header：'+headers.toString());
    }
    var response = await fetchGet(url,headers);
    int status = response.statusCode;
    String body = response.body;
    Map responseHeader = response.headers;
    if (Config.DEBUG) {
      print('返回数据: ${response.statusCode} - ${response.body}');
    }
    if (status == 200 || status == 201 ) {
        if (responseHeader != null && responseHeader['link'] != null){
          try {
            String link = responseHeader['link'];
            if (link != null) {
              int indexStart = link.lastIndexOf("page=") + 5;
              int indexEnd = link.lastIndexOf(">");
              if (indexStart >= 0 && indexEnd >= 0) {
                String count = link.substring(indexStart, indexEnd);
                return int.parse(count);
              }
            }
          } catch (e) {
            print(e);
          }
        }
    }
  }

  /**
   * 用户的前100仓库
   */
  static userRepository100StatusCount() async {

    String token = await LocalStorage.get(Config.TOKEN_KEY);
    Map<String, String> headers = {
      "Authorization": "token "+token
    };

    String userName = await LocalStorage.get(Config.LOGIN_KEY);
    var url = Address.userRepos(userName, 'pushed') + "&page=1&per_page=100";
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
      List list = json.decode(body) as List;
      int stared = 0;
      List<Repository> honorList = List();
      for (int i = 0; i < list.length; i++) {
        var data = list[i];
        Repository repository = new Repository.fromJson(data);
        stared += repository.watchersCount;
        honorList.add(repository);
      }
      //排序
      honorList.sort((r1, r2) => r2.watchersCount - r1.watchersCount);
      return stared;
//      return new DataResult({"stared": stared, "list": honorList}, true);
    }
  }


}