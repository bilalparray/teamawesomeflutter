// services/player_service.dart
import 'package:http/http.dart' as http;
import 'dart:convert';

class PlayerService {
  static List<dynamic> _players = [];
  static dynamic _manOfTheMatch;

  static Future<void> fetchPlayers() async {
    try {
      final response = await http.get(
        Uri.parse('https://teamawesomebackend-sgsc.onrender.com/api/players'),
      );

      if (response.statusCode == 200) {
        _players = json.decode(response.body);
        _calculateManOfTheMatch();
      } else {
        throw Exception('Failed to load players: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching players: $e');
    }
  }

  static void _calculateManOfTheMatch() {
    if (_players.isEmpty) return;

    dynamic motm;
    int highestScore = 0;

    for (var player in _players) {
      if (player['scores'] != null) {
        final scores = player['scores'];
        int runs = scores['runs']?.last != null
            ? int.tryParse(scores['runs'].last) ?? 0
            : 0;
        int wickets = scores['wickets']?.last != null
            ? int.tryParse(scores['wickets'].last) ?? 0
            : 0;
        int total = runs + (wickets * 10); // 1 wicket = 10 runs

        if (total > highestScore) {
          highestScore = total;
          motm = player;
        }
      }
    }

    _manOfTheMatch = motm;
  }

  static List<dynamic> get players => _players;
  static dynamic get manOfTheMatch => _manOfTheMatch;
}
