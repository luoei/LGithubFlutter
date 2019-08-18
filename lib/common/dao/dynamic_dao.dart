import 'dart:convert';

import 'package:github/common/config/config.dart';
import 'package:github/common/dao/dao_result.dart';
import 'package:github/common/local/local_storage.dart';
import 'package:github/common/model/dynamic_item_entity.dart';
import 'package:github/common/net/address.dart';
import 'package:github/common/utils/http_utils.dart';

class DynamicDao {

  static get(int page) async {

    String userName = await LocalStorage.get(Config.LOGIN_KEY);
    var url = Address.getEventReceived(userName) + Address.getPageParams("?", page);
    var response = await HttpUtils.get(url);
    DataResult result;
    switch(response.status){
      case HttpResultStatus.SUCCESS:
        List<DynamicItemEntity> list = (json.decode(response.data) as List).map((e) => DynamicItemEntity.fromJson(e))?.toList();
        result = DataResult(DataResultStatus.SUCESS, data: list);
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