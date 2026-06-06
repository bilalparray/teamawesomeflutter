import 'dart:convert';

import 'package:teamawesomesozeith/environment/environemnt.dart';
import 'package:teamawesomesozeith/services/api_client.dart';

class AdminNextMatchModel {
  final String id;
  final String opponent;
  final bool isSeries;
  final DateTime date;
  final String? seriesName;
  final int? totalMatches;
  final int? matchNumber;
  final String? seriesLeader;
  final int seriesScoreOur;
  final int seriesScoreOpponent;
  final String? venue;
  final int? overs;
  final bool isHomeMatch;
  final String status;

  AdminNextMatchModel({
    required this.id,
    required this.opponent,
    required this.isSeries,
    required this.date,
    this.seriesName,
    this.totalMatches,
    this.matchNumber,
    this.seriesLeader,
    this.seriesScoreOur = 0,
    this.seriesScoreOpponent = 0,
    this.venue,
    this.overs,
    this.isHomeMatch = false,
    this.status = 'upcoming',
  });

  factory AdminNextMatchModel.fromJson(Map<String, dynamic> json) {
    final seriesScore = json['seriesScore'];
    return AdminNextMatchModel(
      id: json['_id']?.toString() ?? '',
      opponent: json['opponent']?.toString() ?? '',
      isSeries: json['isSeries'] == true,
      date: DateTime.tryParse(json['date']?.toString() ?? '') ?? DateTime.now(),
      seriesName: json['seriesName']?.toString(),
      totalMatches: _asInt(json['totalMatches']),
      matchNumber: _asInt(json['matchNumber']),
      seriesLeader: json['seriesLeader']?.toString(),
      seriesScoreOur: seriesScore is Map
          ? (_asInt(seriesScore['ourTeam']) ?? 0)
          : 0,
      seriesScoreOpponent: seriesScore is Map
          ? (_asInt(seriesScore['opponent']) ?? 0)
          : 0,
      venue: json['venue']?.toString(),
      overs: _asInt(json['overs']),
      isHomeMatch: json['isHomeMatch'] == true,
      status: json['status']?.toString() ?? 'upcoming',
    );
  }

  Map<String, dynamic> toPayload() {
    final payload = <String, dynamic>{
      'opponent': opponent.trim(),
      'isSeries': isSeries,
      'date': date.toUtc().toIso8601String(),
      'isHomeMatch': isHomeMatch,
      'status': status,
    };
    if (isSeries) {
      if (seriesName != null && seriesName!.isNotEmpty) {
        payload['seriesName'] = seriesName;
      }
      if (totalMatches != null) payload['totalMatches'] = totalMatches;
      if (matchNumber != null) payload['matchNumber'] = matchNumber;
      if (seriesLeader != null && seriesLeader!.isNotEmpty) {
        payload['seriesLeader'] = seriesLeader;
      }
      payload['seriesScore'] = {
        'ourTeam': seriesScoreOur,
        'opponent': seriesScoreOpponent,
      };
    }
    if (venue != null && venue!.isNotEmpty) payload['venue'] = venue;
    if (overs != null) payload['overs'] = overs;
    return payload;
  }

  static int? _asInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString());
  }
}

class AdminNextMatchService {
  static Future<List<AdminNextMatchModel>> fetchMatches() async {
    final response = await ApiClient.get(
      Uri.parse('${Environment.baseUrl}/api/nextmatch'),
    );
    if (response.statusCode != 200) {
      throw Exception(_message(response.body, 'Failed to load matches'));
    }
    final decoded = jsonDecode(response.body);
    if (decoded is! List) return [];
    return decoded
        .whereType<Map>()
        .map((e) => AdminNextMatchModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  static Future<AdminNextMatchModel> fetchMatch(String id) async {
    final response = await ApiClient.get(
      Uri.parse('${Environment.baseUrl}/api/nextmatch/$id'),
    );
    if (response.statusCode != 200) {
      throw Exception(_message(response.body, 'Failed to load match'));
    }
    return AdminNextMatchModel.fromJson(
      Map<String, dynamic>.from(jsonDecode(response.body) as Map),
    );
  }

  static Future<void> createMatch(AdminNextMatchModel match) async {
    final response = await ApiClient.post(
      Uri.parse('${Environment.baseUrl}/api/nextmatch'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(match.toPayload()),
    );
    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception(_message(response.body, 'Failed to create match'));
    }
  }

  static Future<void> updateMatch(String id, AdminNextMatchModel match) async {
    final response = await ApiClient.put(
      Uri.parse('${Environment.baseUrl}/api/nextmatch/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(match.toPayload()),
    );
    if (response.statusCode != 200) {
      throw Exception(_message(response.body, 'Failed to update match'));
    }
  }

  static Future<void> deleteMatch(String id) async {
    final response = await ApiClient.delete(
      Uri.parse('${Environment.baseUrl}/api/nextmatch/$id'),
    );
    if (response.statusCode != 200) {
      throw Exception(_message(response.body, 'Failed to delete match'));
    }
  }

  static String _message(String body, String fallback) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map && decoded['message'] != null) {
        return decoded['message'].toString();
      }
    } catch (_) {}
    return fallback;
  }
}
