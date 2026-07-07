import 'dart:convert';

import 'package:teamawesomesozeith/environment/environemnt.dart';
import 'package:teamawesomesozeith/services/api_client.dart';

class TeamRulesData {
  final List<String> rules;
  final DateTime? updatedAt;

  TeamRulesData({required this.rules, this.updatedAt});

  factory TeamRulesData.fromJson(Map<String, dynamic> json) {
    final raw = json['rules'];
    final rules =
        raw is List ? raw.map((e) => e.toString()).toList() : <String>[];
    final updatedRaw = json['updatedAt'];
    return TeamRulesData(
      rules: rules,
      updatedAt:
          updatedRaw != null ? DateTime.tryParse(updatedRaw.toString()) : null,
    );
  }
}

enum _TeamRulesAudience { user, admin }

class TeamRulesService {
  /// Loads rules for players (Settings → Team Rules).
  static Future<TeamRulesData> fetchRules() =>
      _fetchRules(audience: _TeamRulesAudience.user);

  /// Loads rules in admin screens (slightly more detail for troubleshooting).
  static Future<TeamRulesData> fetchRulesForAdmin() =>
      _fetchRules(audience: _TeamRulesAudience.admin);

  static Future<TeamRulesData> _fetchRules({
    required _TeamRulesAudience audience,
  }) async {
    final response = await ApiClient.get(
      Uri.parse('${Environment.baseUrl}/api/team-rules'),
    );

    if (response.statusCode != 200) {
      throw Exception(_errorMessage(
        statusCode: response.statusCode,
        body: response.body,
        audience: audience,
        fallback: audience == _TeamRulesAudience.admin
            ? 'Could not load team rules'
            : 'Team rules are not available right now.',
      ));
    }

    final json = _parseJsonMap(
      response.body,
      audience: audience,
      fallback: audience == _TeamRulesAudience.admin
          ? 'Could not read team rules from the server'
          : 'Team rules are not available right now.',
    );
    return TeamRulesData.fromJson(json);
  }

  static Map<String, dynamic> parseJsonMap(
    String body, {
    required String fallback,
    bool forAdmin = false,
  }) =>
      _parseJsonMap(
        body,
        audience:
            forAdmin ? _TeamRulesAudience.admin : _TeamRulesAudience.user,
        fallback: fallback,
      );

  static String errorMessage({
    required int statusCode,
    required String body,
    required String fallback,
    bool forAdmin = false,
  }) =>
      _errorMessage(
        statusCode: statusCode,
        body: body,
        audience:
            forAdmin ? _TeamRulesAudience.admin : _TeamRulesAudience.user,
        fallback: fallback,
      );

  static Map<String, dynamic> _parseJsonMap(
    String body, {
    required _TeamRulesAudience audience,
    required String fallback,
  }) {
    if (_looksLikeHtml(body)) {
      throw Exception(_htmlMessage(audience));
    }

    try {
      final decoded = jsonDecode(body);
      if (decoded is Map) {
        return Map<String, dynamic>.from(decoded);
      }
      throw Exception(fallback);
    } on FormatException {
      throw Exception(
        audience == _TeamRulesAudience.admin
            ? 'Unexpected response from the server. Please try again.'
            : 'Team rules are not available right now. Please try again later.',
      );
    }
  }

  static bool _looksLikeHtml(String body) {
    final trimmed = body.trimLeft().toLowerCase();
    return trimmed.startsWith('<!doctype') ||
        trimmed.startsWith('<html') ||
        trimmed.startsWith('<!');
  }

  static String _htmlMessage(_TeamRulesAudience audience) {
    if (audience == _TeamRulesAudience.admin) {
      return 'Could not reach the team rules service. '
          'Check your connection and try again, or use the web admin page.';
    }
    return 'Team rules are not available right now. Please try again later.';
  }

  static String _errorMessage({
    required int statusCode,
    required String body,
    required _TeamRulesAudience audience,
    required String fallback,
  }) {
    if (_looksLikeHtml(body)) {
      return _htmlMessage(audience);
    }

    try {
      final decoded = jsonDecode(body);
      if (decoded is Map && decoded['message'] != null) {
        final apiMsg = decoded['message'].toString();
        if (audience == _TeamRulesAudience.user) {
          return _sanitizeApiMessageForUser(apiMsg);
        }
        return apiMsg;
      }
    } catch (_) {}

    if (statusCode == 404) {
      return audience == _TeamRulesAudience.admin
          ? 'Team rules could not be found on the server. Please try again.'
          : 'Team rules are not available right now. Please try again later.';
    }
    if (statusCode >= 500) {
      return audience == _TeamRulesAudience.admin
          ? 'Server error. Please try again in a few minutes.'
          : 'Something went wrong. Please try again later.';
    }
    return fallback;
  }

  static String _sanitizeApiMessageForUser(String message) {
    final lower = message.toLowerCase();
    if (lower.contains('deploy') ||
        lower.contains('endpoint') ||
        lower.contains('internal')) {
      return 'Team rules are not available right now. Please try again later.';
    }
    return message;
  }

  /// Strip `Exception: ` prefix for UI display.
  static String displayError(Object error) {
    final text = error.toString();
    const prefix = 'Exception: ';
    if (text.startsWith(prefix)) {
      return text.substring(prefix.length);
    }
    return text;
  }
}
