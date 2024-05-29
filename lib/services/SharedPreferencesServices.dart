import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesServices {
  late SharedPreferences prefs;

  // SharedPreferencesServices() async {
  //   await init();
  // }

  Future<void> init() async {
    prefs = await SharedPreferences.getInstance();
  }

  void setString(String key, String value) {
    prefs.setString(key, value);
  }

  String getString(String key) {
    return prefs.getString(key) ?? "";
  }

  void setBool(String key, bool value) {
    prefs.setBool(key, value);
  }

  bool? getBool(String key) {
    return prefs.getBool(key) ?? false;
  }
}
