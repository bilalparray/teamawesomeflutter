import 'dart:convert';

import 'package:teamawesomesozeith/environment/environemnt.dart';
import 'package:teamawesomesozeith/services/api_client.dart';
import 'package:teamawesomesozeith/services/app_update_service.dart';

class AdminAppInfoService {
  static Future<AppUpdateInfo> fetch() async {
    final response = await ApiClient.get(
      Uri.parse('${Environment.baseUrl}/api/updateapp'),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to load app version settings');
    }
    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw Exception('Invalid app info response');
    }
    return AppUpdateInfo.fromJson(decoded);
  }

  static Future<AppUpdateInfo> save({
    required String minimumVersion,
    required bool isError,
  }) async {
    final response = await ApiClient.put(
      Uri.parse('${Environment.baseUrl}/api/app-info'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'minimumVersion': minimumVersion.trim(),
        'isError': isError,
      }),
    );
    if (response.statusCode != 200) {
      final body = jsonDecode(response.body);
      if (body is Map && body['message'] != null) {
        throw Exception(body['message'].toString());
      }
      throw Exception('Failed to save app version settings');
    }
    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw Exception('Invalid save response');
    }
    return AppUpdateInfo(
      minimumVersion: decoded['minimumVersion']?.toString() ?? minimumVersion,
      isError: decoded['isError'] == true,
    );
  }
}
