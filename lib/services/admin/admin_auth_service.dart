import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:teamawesomesozeith/environment/environemnt.dart';
import 'package:teamawesomesozeith/services/api_client.dart';

class AdminAuthService {
  static const _sessionKey = 'admin_logged_in';

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_sessionKey) ?? false;
  }

  static Future<String?> login(String pin) async {
    final trimmed = pin.trim();
    if (trimmed.isEmpty) return 'Enter admin PIN';

    try {
      final response = await ApiClient.post(
        Uri.parse('${Environment.baseUrl}/api/admin/verify-pin'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'pin': trimmed}),
      );

      if (response.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(_sessionKey, true);
        return null;
      }

      final body = jsonDecode(response.body);
      if (body is Map && body['message'] != null) {
        return body['message'].toString();
      }
      return 'Invalid admin PIN';
    } catch (e) {
      return 'Could not verify PIN: $e';
    }
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey);
  }
}
