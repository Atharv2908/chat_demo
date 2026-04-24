import 'package:shared_preferences/shared_preferences.dart';

class PrefsService {

  /// THEME
  static const String themeKey = 'theme_mode';

  static Future<void> saveTheme(bool isDaek) async {

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(themeKey, isDaek);
  }

  static Future<bool> getTheme() async {

    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(themeKey) ?? false; // Default to light theme
  }

  /// AUTHENTICATION
  static const lastActiveKey = 'last_active';

  static Future<void> updateLastActive() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(lastActiveKey, DateTime.now().millisecondsSinceEpoch);
  }

  static Future<DateTime?> getLastActive() async {
    final prefs = await SharedPreferences.getInstance();

    final value = prefs.getInt(lastActiveKey);

    return value != null ? DateTime.fromMillisecondsSinceEpoch(value) : null; // No last active time found
  }

  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(lastActiveKey);
  }
}