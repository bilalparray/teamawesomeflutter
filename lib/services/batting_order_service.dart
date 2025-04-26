import 'dart:convert';
import 'package:http/http.dart' as http;

class BattingOrderService {
  static Future<List<String>> fetchBattingOrder() async {
    final response = await http.get(Uri.parse(
        'https://teamawesomebackend-sgsc.onrender.com/api/batting-order'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List<dynamic> orderList = data['order'];
      return orderList.map((e) => e.toString()).toList();
    } else {
      throw Exception('Failed to load batting order');
    }
  }
}
