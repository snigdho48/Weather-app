import 'package:shared_preferences/shared_preferences.dart';

const String prefUnit = 'Unit';
const String prefTimeFormat = 'TimeFormat';
const String prefDefaultCity = 'DefaultCity';

Future<bool> setBool(String key, bool status) async {
  final pref = await SharedPreferences.getInstance();
  return pref.setBool(key, status);
}

Future<bool> getBool(String key) async {
  final pref = await SharedPreferences.getInstance();
  return pref.getBool(key) ?? false;
}
