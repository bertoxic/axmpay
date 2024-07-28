import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesUtil {
  static SharedPreferences? _prefs;

  static Future<SharedPreferences> getInstance() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  static Future<void> saveString(String? key, String? value) async {
    final prefs = await getInstance();
    await prefs.setString(key!??"",value??"");
  }

  static Future<String?> getString(String key) async {
    final prefs = await getInstance();
    return prefs.getString(key);
  }
}

