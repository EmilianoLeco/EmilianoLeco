import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static const _keyHasOnboarded = 'has_onboarded';
  static const _keyUserRole = 'user_role';

  static Future<bool> hasOnboarded() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyHasOnboarded) ?? false;
  }

  static Future<void> completeOnboarding(String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyHasOnboarded, true);
    await prefs.setString(_keyUserRole, role);
  }

  static Future<String> getUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserRole) ?? 'remitente';
  }
}
