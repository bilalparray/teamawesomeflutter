import 'dart:convert';

import 'package:teamawesomesozeith/environment/environemnt.dart';
import 'package:teamawesomesozeith/services/api_client.dart';

class AdminBattingOrderService {
  static Future<void> saveOrder(List<String> order) async {
    final response = await ApiClient.put(
      Uri.parse('${Environment.baseUrl}/api/batting-order'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'reqData': {'order': order},
      }),
    );

    if (response.statusCode != 200) {
      final body = jsonDecode(response.body);
      throw Exception(
          body is Map ? body['message'] ?? 'Save failed' : 'Save failed');
    }
  }
}
