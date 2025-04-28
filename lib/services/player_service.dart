// services/player_service.dart
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:teamawesomesozeith/environment/environemnt.dart';

class PlayerService {
  static List<dynamic> _players = [];
  static dynamic _manOfTheMatch;

  /// Fetches from API only if we haven't already in this app session.
  static Future<void> fetchPlayers() async {
    if (_players.isNotEmpty) return; // <<–– already fetched this session

    final response = await http.get(
      Uri.parse('${Environment.baseUrl}/api/players'),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load players: ${response.statusCode}');
    }

    _players = json.decode(response.body);
    _calculateManOfTheMatch();
  }

  static void _calculateManOfTheMatch() {
    if (_players.isEmpty) return;

    dynamic motm;
    int highestScore = 0;

    for (var p in _players) {
      final scores = p['scores'];
      if (scores == null) continue;

      int runs = 0, wickets = 0;
      if (scores['runs']?.isNotEmpty == true) {
        runs = int.tryParse(scores['runs'].last) ?? 0;
      }
      if (scores['wickets']?.isNotEmpty == true) {
        wickets = int.tryParse(scores['wickets'].last) ?? 0;
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
