import 'dart:convert';

import 'package:teamawesomesozeith/environment/environemnt.dart';
import 'package:teamawesomesozeith/services/api_client.dart';
import 'package:teamawesomesozeith/services/player_service.dart';

class AdminPlayerService {
  static Future<List<Map<String, dynamic>>> fetchPlayers({
    bool forceRefresh = true,
  }) async {
    await PlayerService.fetchPlayers(forceRefresh: forceRefresh);
    return PlayerService.players
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  static Future<Map<String, dynamic>> fetchPlayer(String playerId) async {
    final response = await ApiClient.get(
      Uri.parse('${Environment.baseUrl}/api/data/$playerId'),
    );
    if (response.statusCode != 200) {
      throw Exception(_messageFromBody(response.body, 'Failed to load player'));
    }
    return Map<String, dynamic>.from(jsonDecode(response.body) as Map);
  }

  static Future<void> appendScores({
    required String playerId,
    required List<int> runs,
    required List<int> balls,
    required List<int> wickets,
  }) async {
    final response = await ApiClient.put(
      Uri.parse('${Environment.baseUrl}/api/data/$playerId'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'runs': runs.map((e) => e.toString()).toList(),
        'balls': balls.map((e) => e.toString()).toList(),
        'wickets': wickets.map((e) => e.toString()).toList(),
      }),
    );
    if (response.statusCode != 200) {
      throw Exception(_messageFromBody(response.body, 'Failed to update scores'));
    }
  }

  static Future<void> updateProfile({
    required String playerId,
    required Map<String, dynamic> fields,
  }) async {
    final response = await ApiClient.put(
      Uri.parse('${Environment.baseUrl}/api/update/$playerId'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(fields),
    );
    if (response.statusCode != 200) {
      throw Exception(_messageFromBody(response.body, 'Failed to update profile'));
    }
  }

  static Future<void> addWicket({
    required String playerId,
    required int wicket,
  }) async {
    final response = await ApiClient.put(
      Uri.parse('${Environment.baseUrl}/api/update/$playerId/wicket'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'wicket': wicket}),
    );
    if (response.statusCode != 200) {
      throw Exception(_messageFromBody(response.body, 'Failed to add wicket'));
    }
  }

  static Future<void> updateLast({
    required String playerId,
    int? runs,
    int? balls,
    int? wickets,
  }) async {
    final body = <String, dynamic>{};
    if (runs != null) body['runs'] = runs;
    if (balls != null) body['balls'] = balls;
    if (wickets != null) body['wickets'] = wickets;

    final response = await ApiClient.put(
      Uri.parse('${Environment.baseUrl}/api/update/$playerId/last'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    if (response.statusCode != 200) {
      throw Exception(_messageFromBody(response.body, 'Failed to update last slot'));
    }
  }

  static Future<void> createPlayer({
    required String name,
    required String role,
    String? born,
    String? birthplace,
    String? battingstyle,
    String? bowlingstyle,
    String? debut,
    String? imageBase64,
  }) async {
    final response = await ApiClient.post(
      Uri.parse('${Environment.baseUrl}/api/data'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'role': role,
        if (born != null && born.isNotEmpty) 'born': born,
        if (birthplace != null && birthplace.isNotEmpty) 'birthplace': birthplace,
        if (battingstyle != null && battingstyle.isNotEmpty)
          'battingstyle': battingstyle,
        if (bowlingstyle != null && bowlingstyle.isNotEmpty)
          'bowlingstyle': bowlingstyle,
        if (debut != null && debut.isNotEmpty) 'debut': debut,
        if (imageBase64 != null && imageBase64.isNotEmpty) 'image': imageBase64,
      }),
    );
    if (response.statusCode != 200) {
      throw Exception(_messageFromBody(response.body, 'Failed to add player'));
    }
  }

  static List<int> parseCommaNumbers(String input) {
    return input
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .map((s) => int.tryParse(s))
        .whereType<int>()
        .toList();
  }

  static String _messageFromBody(String body, String fallback) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map && decoded['message'] != null) {
        return decoded['message'].toString();
      }
    } catch (_) {}
    return fallback;
  }
}
