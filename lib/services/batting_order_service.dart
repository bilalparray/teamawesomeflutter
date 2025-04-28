import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:teamawesomesozeith/environment/environemnt.dart';

class BattingOrderService {
  static Future<List<String>> fetchBattingOrder() async {
    final response =
        await http.get(Uri.parse('${Environment.baseUrl}/api/batting-order'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List<dynamic> orderList = data['order'];
      return orderList.map((e) => e.toString()).toList();
    } else {
      throw Exception('Failed to load batting order');
    }
  }
}
