import 'package:shared_preferences/shared_preferences.dart';

void saveDataToSession(String key, String value) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString(key, value);
}

void saveDataToSessionBoolean(String key, bool value) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setBool(key, value);
}

Future<String?> getDataFromSession(String key) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString(key);
}

void clearSessionData() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.clear();
}
