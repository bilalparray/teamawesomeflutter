import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:teamawesomesozeith/environment/environemnt.dart';
import 'package:teamawesomesozeith/services/api_client.dart';

class ScorecardApplyResult {
  final int updatedCount;
  final int skippedCount;
  final String message;

  ScorecardApplyResult({
    required this.updatedCount,
    required this.skippedCount,
    required this.message,
  });

  factory ScorecardApplyResult.fromJson(Map<String, dynamic> json) {
    return ScorecardApplyResult(
      updatedCount: json['updatedCount'] as int? ?? 0,
      skippedCount: json['skippedCount'] as int? ?? 0,
      message: json['message']?.toString() ?? 'Done',
    );
  }
}

class AdminScorecardService {
  static Future<List<String>> extractPlayers({
    required List<int> pdfBytes,
    required String filename,
  }) async {
    final response = await ApiClient.postMultipart(
      uri: Uri.parse('${Environment.baseUrl}/api/scorecard/extract-players'),
      fileField: 'pdf',
      fileBytes: pdfBytes,
      filename: filename,
    );

    if (response.statusCode != 200) {
      final body = jsonDecode(response.body);
      throw Exception(
          body is Map ? body['message'] ?? 'Extract failed' : 'Extract failed');
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! List) throw Exception('Unexpected extract response');
    return decoded.map((e) => e.toString()).toList();
  }

  static Future<List<Map<String, dynamic>>> processScorecard({
    required List<int> pdfBytes,
    required String filename,
    required List<String> latePlayers,
  }) async {
    final response = await ApiClient.postMultipart(
      uri: Uri.parse('${Environment.baseUrl}/api/scorecard/process'),
      fileField: 'pdf',
      fileBytes: pdfBytes,
      filename: filename,
      fields: {'latePlayers': jsonEncode(latePlayers)},
    );

    if (response.statusCode != 200) {
      final body = jsonDecode(response.body);
      throw Exception(
          body is Map ? body['message'] ?? 'Process failed' : 'Process failed');
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! List) throw Exception('Unexpected process response');
    final parserVer = response.headers['x-scorecard-parser-version'];
    final rows = decoded
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
    if (parserVer != null && (int.tryParse(parserVer) ?? 0) < 7) {
      // Old backend may return zeros — still return data for manual edit.
      debugPrint('Scorecard parser v$parserVer (expected 7+)');
    }
    return rows;
  }

  static Future<ScorecardApplyResult> applyToDb(
      List<Map<String, dynamic>> players) async {
    final response = await ApiClient.post(
      Uri.parse('${Environment.baseUrl}/api/scorecard/apply-to-db'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'players': players}),
    );

    if (response.statusCode != 200) {
      final body = jsonDecode(response.body);
      throw Exception(
          body is Map ? body['message'] ?? 'Apply failed' : 'Apply failed');
    }

    return ScorecardApplyResult.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }
}
