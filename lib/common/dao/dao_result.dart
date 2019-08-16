
enum DataResultStatus {
  SUCESS, // 成功
  TIMEOUT, //超时
  NoNetwork, //无网络
  FAILURE, // 其它失败
}

class DataResult {

  DataResultStatus status;

  int code;

  String message;

  // 返回的业务数据
  var data;

  DataResult(this.status, {this.code,this.data, this.message});

}

enum HttpResultStatus {
  SUCCESS, //成功
  TIMEOUT, //超时
  NoNetwork, //无网络
  FAILURE, // 其它失败
}

class HttpResult {

  HttpResultStatus status;

  String message;

  int code;

  var data;

  HttpResult(this.status, {this.code, this.message, this.data});

}