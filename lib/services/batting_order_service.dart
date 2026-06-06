import 'dart:convert';
import 'package:teamawesomesozeith/environment/environemnt.dart';
import 'package:teamawesomesozeith/services/api_client.dart';

class BattingOrderService {
  static Future<List<String>> fetchBattingOrder() async {
    final response =
        await ApiClient.get(Uri.parse('${Environment.baseUrl}/api/batting-order'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List<dynamic> orderList = data['order'];
      return orderList.map((e) => e.toString()).toList();
    } else {
      throw Exception('Failed to load batting order');
    }
  }
}
