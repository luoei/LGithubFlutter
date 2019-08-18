import 'package:github/common/model/dynamic_item_entity.dart';
import 'package:github/common/model/user_entity.dart';

class EntityFactory {
  static T generateOBJ<T>(json) {
    if (1 == 0) {
      return null;
    } else if (T.toString() == "UserEntity") {
      return User.fromJson(json) as T;
    } else if (T.toString() == "DynamicItemEntity") {
      return DynamicItemEntity.fromJson(json) as T;
    } else {
      return null;
    }
  }
}