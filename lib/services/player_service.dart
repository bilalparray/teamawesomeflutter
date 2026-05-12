// services/player_service.dart
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:teamawesomesozeith/environment/environemnt.dart';

class PlayerService {
  static List<dynamic> _players = [];
  static dynamic _manOfTheMatch;

  /// JSON from Mongo may use int or String for score entries (post-migration).
  static int _coerceInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString()) ?? 0;
  }

  /// Fetches from API only if we haven't already in this app session.
  static Future<void> fetchPlayers({bool forceRefresh = false}) async {
    if (_players.isNotEmpty && !forceRefresh) {
      return; // already fetched and no explicit refresh requested
    }

    final response = await http.get(
      Uri.parse('${Environment.baseUrl}/api/players'),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load players: ${response.statusCode}');
    }

    final decoded = json.decode(response.body);
    if (decoded is! List) {
      throw Exception(
        'Failed to load players: expected JSON array, got ${decoded.runtimeType}',
      );
    }
    _players = decoded;
    _calculateManOfTheMatch();
  }

  static void _calculateManOfTheMatch() {
    if (_players.isEmpty) return;

    dynamic motm;
    int highestScore = 0;

    for (var p in _players) {
      if (p is! Map) continue;
      final scores = p['scores'];
      if (scores is! Map) continue;

      int runs = 0, wickets = 0;
      final runsList = scores['runs'];
      if (runsList is List && runsList.isNotEmpty) {
        runs = _coerceInt(runsList.last);
      }
      final wktsList = scores['wickets'];
      if (wktsList is List && wktsList.isNotEmpty) {
        wickets = _coerceInt(wktsList.last);
      }
      final total = runs + wickets * 10;
      if (total > highestScore) {
        highestScore = total;
        motm = p;
      }
    }

    _manOfTheMatch = motm;
  }

  static List<dynamic> get players => _players;
  static dynamic get manOfTheMatch => _manOfTheMatch;
}
