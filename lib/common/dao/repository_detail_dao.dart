import 'dart:convert';

import 'package:github/common/config/config.dart';
import 'package:github/common/local/local_storage.dart';
import 'package:github/common/model/Event.dart';
import 'package:github/common/model/FileModel.dart';
import 'package:github/common/model/Issue.dart';
import 'package:github/common/model/RepoCommit.dart';
import 'package:github/common/model/Repository.dart';
import 'package:github/common/net/address.dart';
import 'package:http/http.dart' as http;

class RepositoryDetailDao {

  static Future<http.Response> fetchGet(String url,Map<String, String> header) async {
    return await http.get(url,headers: header);
  }


  static getRepositoryDetailInfo(String repoOwner,String repoName, String branch) async {

    String token = await LocalStorage.get(Config.TOKEN_KEY);
    Map<String, String> headers = {
      "Authorization": "token "+token,
      "Accept": 'application/vnd.github.mercy-preview+json'
    };

    var url = Address.getReposDetail(repoOwner, repoName)+"?ref=" + branch;
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
      Repository repository = Repository.fromJson(json.decode(body));
      return repository;
    }
    return null;
  }

  static getBranchesDao(String repoOwner, String repoName) async {

    String token = await LocalStorage.get(Config.TOKEN_KEY);
    Map<String, String> headers = {
      "Authorization": "token "+token
    };

    var url = Address.getbranches(repoOwner, repoName);
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
      List<String> list = new List();
      (json.decode(body) as List).forEach((data){
        list.add(data['name']);
      });
      return list;
    }

  }

  static getRepositoryEventDao(String repoOwner, String repoName, {page = 0, branch = "master"}) async {

    String token = await LocalStorage.get(Config.TOKEN_KEY);
    Map<String, String> headers = {
      "Authorization": "token "+token
    };

    var url = Address.getReposEvent(repoOwner, repoName) +
        Address.getPageParams("?", page);
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

  static getReposCommitsDao(String repoOwner, String repoName, {page = 0, branch = "master"}) async {

    String token = await LocalStorage.get(Config.TOKEN_KEY);
    Map<String, String> headers = {
      "Authorization": "token "+token
    };

    var url = Address.getReposCommits(repoOwner, repoName) +
        Address.getPageParams("?", page) + "&sha=" + branch;
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
      List<RepoCommit> list = (json.decode(body) as List).map((e) {
        RepoCommit event = RepoCommit.fromJson(e);
        return event;
      })?.toList();
      return list;
    }

  }

  static getRepositoryDetailReadmeDao(String repoOwner, String repoName, {branch = "master"}) async {

    String token = await LocalStorage.get(Config.TOKEN_KEY);
    Map<String, String> headers = {
      "Authorization": "token "+token,
      "Accept": 'application/vnd.github.VERSION.raw'
    };

    String url = Address.readmeFile(repoOwner + '/' + repoName, branch);
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
      return body;
    }

  }

  /**
   * @param state issue状态
   * @param sort 排序类型 created updated等
   * @param direction 正序或者倒序
   */
  static getRepositoryIssueDao(String repoOwner, String repoName, state, {sort, direction, page = 0, branch = "master"}) async {

    String token = await LocalStorage.get(Config.TOKEN_KEY);
    Map<String, String> headers = {
      "Authorization": "token "+token
    };

    String url = Address.getReposIssue(repoOwner, repoName, state, sort, direction) + Address.getPageParams("&", page);
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
      List<Issue> list = (json.decode(body) as List).map((e) {
        Issue event = Issue.fromJson(e);
        return event;
      })?.toList();
      return list;
    }

  }

  static getReposFileDirDao(String repoOwner, String repoName, {path = '', isHtml = false, branch = "master"}) async {

    String token = await LocalStorage.get(Config.TOKEN_KEY);
    Map<String, String> headers = {
      "Authorization": "token "+token,
      "Accept": isHtml ? "Accept: application/vnd.github.html" : 'application/vnd.github.mercy-preview+json'
    };

    String url = Address.reposDataDir(repoOwner, repoName, path, branch);
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

      if(isHtml){
        return body;
      }

      List<FileModel> originList = (json.decode(body) as List).map((e) {
        FileModel event = FileModel.fromJson(e);
        return event;
      })?.toList();
      List<FileModel> dirList = [];
      List<FileModel> fileList = [];
      List<FileModel> resultList = new List();
      originList.forEach((model){
        if (model.type == 'file'){
          fileList.add(model);
        }else{
          dirList.add(model);
        }
      });
      dirList.sort((obj1, obj2){
        return obj1.name.compareTo(obj2.name);
      });
      fileList.sort((obj1, obj2){
        return obj1.name.compareTo(obj2.name);
      });
      resultList.addAll(dirList);
      resultList.addAll(fileList);
      return resultList;
    }
    return null;
  }

}