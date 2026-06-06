// lib/services/match_service.dart
import 'dart:convert';
import 'package:teamawesomesozeith/environment/environemnt.dart';
import 'package:teamawesomesozeith/services/api_client.dart';
import '../models/match_model.dart';

class MatchService {
  static final List<MatchModel> _matches = [];

  static List<MatchModel> get matches => List.unmodifiable(_matches);

  /// Clears cached matches (e.g. after a partial load failure).
  static void clearMatches() {
    _matches.clear();
  }

  static Future<void> fetchMatches({bool forceRefresh = false}) async {
    if (_matches.isNotEmpty && !forceRefresh) return; // already fetched

    final response =
        await ApiClient.get(Uri.parse('${Environment.baseUrl}/api/nextmatch'));

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
