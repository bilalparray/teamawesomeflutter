import 'package:intl/intl.dart';

class PlayerDataProcessor {
  static Map<String, String> processRecentScores(Map<String, dynamic> scores) {
    final runs = _toNumList(scores['runs']);
    final wkts = _toNumList(scores['wickets']);
    final balls = _toNumList(scores['balls']);
    final lastRuns = runs.isNotEmpty ? runs.last : 0;
    final lastWkts = wkts.isNotEmpty ? wkts.last : 0;
    final lastBalls = balls.isNotEmpty ? balls.last : 0;

    return {
      'Runs': lastRuns.toString(),
      'Wickets': lastWkts.toString(),
      'Strike%': _strikeRate([lastRuns], [lastBalls]),
      'Balls': lastBalls.toString(),
    };
  }

  static Map<String, String> processYearScores(Map<String, dynamic> scores) {
    final runs = _toNumList(scores['runs']);
    final wkts = _toNumList(scores['wickets']);
    final balls = _toNumList(scores['balls']);
    final fifties = runs.where((r) => r >= 50 && r < 100).length;
    final hundreds = runs.where((r) => r >= 100).length;

    return {
      'Total Runs': _sum(runs),
      'Total Wkts': _sum(wkts),
      'Matches': runs.length.toString(),
      'Avg': _average(runs),
      'Strike%': _strikeRate(runs, balls),
      '50s': fifties.toString(),
      '100s': hundreds.toString(),
      'Best': _max(runs),
      'Balls': _sum(balls),
    };
  }

  static Map<String, String> processCareerScores(Map<String, dynamic> career) {
    final runs = _toNumList(career['runs']);
    final wkts = _toNumList(career['wickets']);
    final balls = _toNumList(career['balls']);
    final fifties = runs.where((r) => r >= 50 && r < 100).length;
    final hundreds = runs.where((r) => r >= 100).length;

    return {
      'Rank': career['ranking'].toString(),
      'Career Runs': _sum(runs),
      'Career Wkts': _sum(wkts),
      'Matches': runs.length.toString(),
      'Avg': _average(runs),
      'Strike%': _strikeRate(runs, balls),
      '50s': fifties.toString(),
      '100s': hundreds.toString(),
      'Best': _max(runs),
      'Balls': _sum(balls),
    };
  }

  static Map<String, String> processRunsScores(Map<String, dynamic> scores) {
    final runs = _toNumList(scores['runs']);
    return {
      for (var i = runs.length - 1; i >= 0; i--)
        'Match ${i + 1}': runs[i].toString()
    };
  }

  static Map<String, String> processWicketsScores(Map<String, dynamic> scores) {
    final wkts = _toNumList(scores['wickets']);
    return {
      for (var i = wkts.length - 1; i >= 0; i--)
        'Match ${i + 1}': wkts[i].toString()
    };
  }

  static List<num> _toNumList(dynamic data) => data is List
      ? data.whereType<String>().map((s) => num.tryParse(s) ?? 0).toList()
      : <num>[];

  static String _sum(List<num> v) =>
      v.isEmpty ? '0' : v.fold<num>(0, (a, b) => a + b).toString();

  static String _average(List<num> v) => v.isEmpty
      ? 'N/A'
      : (v.reduce((a, b) => a + b) / v.length).toStringAsFixed(2);

  static String _strikeRate(List<num> runs, List<num> balls) {
    final totalRuns = runs.fold<double>(0, (a, b) => a + b);
    final totalBalls = balls.fold<double>(0, (a, b) => a + b);
    return (totalRuns == 0 || totalBalls == 0)
        ? 'N/A'
        : ((totalRuns / totalBalls) * 100).toStringAsFixed(2);
  }

  static String _max(List<num> v) =>
      v.isEmpty ? 'N/A' : v.reduce((a, b) => a > b ? a : b).toString();

  static String parseDate(String? date) {
    if (date == null) return 'N/A';
    try {
      return DateFormat('dd MMM yyyy').format(DateTime.parse(date));
    } catch (_) {
      return 'N/A';
    }
  }
}
