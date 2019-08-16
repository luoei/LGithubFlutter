import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {

  static save(String key, value) async {
      SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
      sharedPreferences.setString(key, value);
  }

  static get(String key) async {
      SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
      return sharedPreferences.get(key);
  }

  static remove(String key) async {
      SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
      sharedPreferences.remove(key);
  }

}