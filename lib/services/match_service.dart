// lib/services/match_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:teamawesomesozeith/environment/environemnt.dart';
import '../models/match_model.dart';

class MatchService {
  static final List<MatchModel> _matches = [];

  static List<MatchModel> get matches => List.unmodifiable(_matches);

  static Future<void> fetchMatches() async {
    if (_matches.isNotEmpty) return; // already fetched

    final response =
        await http.get(Uri.parse('${Environment.baseUrl}/api/nextmatch'));

    if (response.statusCode != 200) {
      throw Exception('Failed to load matches: ${response.statusCode}');
    }

    final decoded = json.decode(response.body);

    // Backend returns a JSON array (as in your Postman output)
    if (decoded is List) {
      _matches.clear();
      for (var item in decoded) {
        if (item is Map<String, dynamic>) {
          _matches.add(MatchModel.fromJson(item));
        } else {
          _matches.add(MatchModel.fromJson(Map<String, dynamic>.from(item)));
        }
      }
    } else {
      throw Exception('Unexpected response format for matches');
    }
  }
}
