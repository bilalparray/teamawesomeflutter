import 'dart:convert';

import 'package:teamawesomesozeith/environment/environemnt.dart';
import 'package:teamawesomesozeith/models/mate_turn_model.dart';
import 'package:teamawesomesozeith/services/api_client.dart';

class UpcomingMateTurn {
  final DateTime date;
  final int groupNumber;
  final String playersLabel;
  final String notes;
  final bool isRecorded;

  const UpcomingMateTurn({
    required this.date,
    required this.groupNumber,
    required this.playersLabel,
    this.notes = '',
    this.isRecorded = false,
  });
}

class MateTurnService {
  static List<MateTurnModel> _turns = [];
  static MateTurnSuggested? _suggested;

  static List<MateTurnModel> get turns => List.unmodifiable(_turns);
  static MateTurnSuggested? get suggested => _suggested;

  static DateTime _startOfDay(DateTime d) =>
      DateTime(d.year, d.month, d.day);

  static Future<void> fetchTurns({bool forceRefresh = false}) async {
    if (_turns.isNotEmpty && !forceRefresh) return;

    final response =
        await ApiClient.get(Uri.parse('${Environment.baseUrl}/api/mate-turns'));

    if (response.statusCode != 200) {
      throw Exception('Failed to load mate turns: ${response.statusCode}');
    }

    final decoded = json.decode(response.body);
    if (decoded is! List) {
      throw Exception('Unexpected mate turns response format');
    }

    _turns = decoded
        .whereType<Map>()
        .map((e) => MateTurnModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  static Future<MateTurnSuggested?> fetchSuggested() async {
    final response = await ApiClient.get(
        Uri.parse('${Environment.baseUrl}/api/mate-turns/suggested'));

    if (response.statusCode == 404) {
      _suggested = null;
      return null;
    }

    if (response.statusCode != 200) {
      throw Exception('Failed to load suggested mate turn: ${response.statusCode}');
    }

    final decoded = json.decode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw Exception('Unexpected suggested mate turn response format');
    }

    _suggested = MateTurnSuggested.fromJson(decoded);
    return _suggested;
  }

  static Future<void> fetchAll({bool forceRefresh = false}) async {
    await fetchTurns(forceRefresh: forceRefresh);
    try {
      await fetchSuggested();
    } catch (_) {
      _suggested = null;
    }
  }

  static void clearCache() {
    _turns = [];
    _suggested = null;
  }

  /// Next upcoming entry: recorded future turn, or API suggestion.
  static UpcomingMateTurn? getUpcoming() {
    final today = _startOfDay(DateTime.now());

    MateTurnModel? nearestFuture;
    for (final turn in _turns) {
      final turnDay = _startOfDay(turn.date.toLocal());
      if (turnDay.isBefore(today)) continue;
      if (nearestFuture == null ||
          turnDay.isBefore(_startOfDay(nearestFuture.date.toLocal()))) {
        nearestFuture = turn;
      }
    }

    if (nearestFuture != null) {
      return UpcomingMateTurn(
        date: nearestFuture.date,
        groupNumber: nearestFuture.groupNumber,
        playersLabel: nearestFuture.playersLabel,
        notes: nearestFuture.notes,
        isRecorded: true,
      );
    }

    final s = _suggested;
    if (s == null) return null;

    return UpcomingMateTurn(
      date: s.suggestedDate,
      groupNumber: s.suggestedGroupNumber,
      playersLabel: s.playersLabel,
      notes: s.note ?? '',
      isRecorded: false,
    );
  }
}
