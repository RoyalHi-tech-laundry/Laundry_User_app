import 'package:shared_preferences/shared_preferences.dart';

class AuthStorageService {
  // Keys for SharedPreferences
  static const String _tokenKey = 'auth_token';
  static const String _userIdKey = 'user_id';
  static const String _userNameKey = 'user_name';
  static const String _userPhoneKey = 'user_phone';
  static const String _userEmailKey = 'user_email';
  static const String _userRoleKey = 'user_role';
  static const String _lastSelectedAddressKey = 'last_selected_address';

  // Save token to SharedPreferences
  static Future<bool> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.setString(_tokenKey, token);
  }

  // Get token from SharedPreferences
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // Get user role from SharedPreferences
  static Future<String?> getUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userRoleKey);
  }

  // Save last selected address
  static Future<bool> saveLastSelectedAddress(String addressJson) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.setString(_lastSelectedAddressKey, addressJson);
  }

  // Get last selected address
  static Future<String?> getLastSelectedAddress() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_lastSelectedAddressKey);
  }

  // Clear last selected address
  static Future<bool> clearLastSelectedAddress() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.remove(_lastSelectedAddressKey);
  }

  // Save user details to SharedPreferences
  static Future<void> saveUserDetails({
    required int id,
    required String name,
    required String phone,
    required String email,
    required String role,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_userIdKey, id);
    await prefs.setString(_userNameKey, name);
    await prefs.setString(_userPhoneKey, phone);
    await prefs.setString(_userEmailKey, email);
    await prefs.setString(_userRoleKey, role);
  }

  // Get user details from SharedPreferences
  static Future<Map<String, dynamic>> getUserDetails() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'id': prefs.getInt(_userIdKey) ?? 0,
      'name': prefs.getString(_userNameKey) ?? '',
      'phone': prefs.getString(_userPhoneKey) ?? '',
      'email': prefs.getString(_userEmailKey) ?? '',
      'role': prefs.getString(_userRoleKey) ?? '',
    };
  }

  // Clear all auth data from SharedPreferences (for logout)
  static Future<void> clearAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userIdKey);
    await prefs.remove(_userNameKey);
    await prefs.remove(_userPhoneKey);
    await prefs.remove(_userEmailKey);
    await prefs.remove(_userRoleKey);
    await prefs.remove(_lastSelectedAddressKey);
  }

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}
