import 'dart:convert';

import 'package:teamawesomesozeith/environment/environemnt.dart';
import 'package:teamawesomesozeith/models/mate_turn_model.dart';
import 'package:teamawesomesozeith/services/api_client.dart';

class MateGroupEntry {
  final int groupNumber;
  final List<String> playerIds;
  final List<String> playerNames;

  MateGroupEntry({
    required this.groupNumber,
    required this.playerIds,
    required this.playerNames,
  });

  factory MateGroupEntry.fromJson(Map<String, dynamic> json) {
    return MateGroupEntry(
      groupNumber: json['groupNumber'] as int? ?? 0,
      playerIds: (json['playerIds'] as List? ?? [])
          .map((e) => e.toString())
          .toList(),
      playerNames: (json['playerNames'] as List? ?? [])
          .map((e) => e.toString())
          .toList(),
    );
  }
}

class AdminMateTurnService {
  static Future<List<MateGroupEntry>> fetchGroups() async {
    final response =
        await ApiClient.get(Uri.parse('${Environment.baseUrl}/api/mate-groups'));
    if (response.statusCode != 200) {
      throw Exception('Failed to load mate groups');
    }
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final groups = data['groups'] as List? ?? [];
    return groups
        .whereType<Map>()
        .map((e) => MateGroupEntry.fromJson(Map<String, dynamic>.from(e)))
        .toList()
      ..sort((a, b) => a.groupNumber.compareTo(b.groupNumber));
  }

  static Future<void> saveGroups(
      List<Map<String, dynamic>> groupsPayload) async {
    final response = await ApiClient.put(
      Uri.parse('${Environment.baseUrl}/api/mate-groups'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'groups': groupsPayload}),
    );
    if (response.statusCode != 200) {
      final body = jsonDecode(response.body);
      throw Exception(
          body is Map ? body['message'] ?? 'Save failed' : 'Save failed');
    }
  }

  static Future<MateTurnSuggested?> fetchSuggested() async {
    final response = await ApiClient.get(
      Uri.parse('${Environment.baseUrl}/api/mate-turns/suggested'),
    );
    if (response.statusCode == 404) return null;
    if (response.statusCode != 200) {
      throw Exception('Failed to load suggestion');
    }
    return MateTurnSuggested.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  static Future<List<MateTurnModel>> fetchTurns() async {
    final response =
        await ApiClient.get(Uri.parse('${Environment.baseUrl}/api/mate-turns'));
    if (response.statusCode != 200) {
      throw Exception('Failed to load mate turns');
    }
    final list = jsonDecode(response.body) as List;
    return list
        .whereType<Map>()
        .map((e) => MateTurnModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  static Future<void> createTurn(Map<String, dynamic> body) async {
    final response = await ApiClient.post(
      Uri.parse('${Environment.baseUrl}/api/mate-turns'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    if (response.statusCode != 201) {
      final decoded = jsonDecode(response.body);
      throw Exception(
          decoded is Map ? decoded['message'] ?? 'Save failed' : 'Save failed');
    }
  }

  static Future<void> updateTurn(String id, Map<String, dynamic> body) async {
    final response = await ApiClient.put(
      Uri.parse('${Environment.baseUrl}/api/mate-turns/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    if (response.statusCode != 200) {
      final decoded = jsonDecode(response.body);
      throw Exception(
          decoded is Map ? decoded['message'] ?? 'Update failed' : 'Update failed');
    }
  }

  static Future<void> deleteTurn(String id) async {
    final response = await ApiClient.delete(
      Uri.parse('${Environment.baseUrl}/api/mate-turns/$id'),
    );
    if (response.statusCode != 200) {
      final decoded = jsonDecode(response.body);
      throw Exception(
          decoded is Map ? decoded['message'] ?? 'Delete failed' : 'Delete failed');
    }
  }
}
