// lib/models/match_model.dart
class MatchModel {
  final String id;
  final String opponent;
  final bool isSeries;
  final DateTime? date;
  final int? ourTeamScore;
  final int? opponentScore;
  final String? venue;
  final int? overs;
  final bool isHomeMatch;
  final String status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  MatchModel({
    required this.id,
    required this.opponent,
    required this.isSeries,
    this.date,
    this.ourTeamScore,
    this.opponentScore,
    this.venue,
    this.overs,
    required this.isHomeMatch,
    required this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory MatchModel.fromJson(Map<String, dynamic> json) {
    int? parseNullableInt(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      return int.tryParse(v.toString());
    }

    DateTime? parseDate(dynamic v) {
      if (v == null) return null;
      try {
        // Date string like "2025-08-31T04:30:00.000Z" is parseable by DateTime.parse
        return DateTime.parse(v.toString());
      } catch (_) {
        return null;
      }
    }

    final seriesScore = json['seriesScore'];
    return MatchModel(
      id: json['_id']?.toString() ?? '',
      opponent: json['opponent']?.toString() ?? '',
      isSeries: json['isSeries'] is bool
          ? json['isSeries'] as bool
          : (json['isSeries']?.toString().toLowerCase() == 'true'),
      date: parseDate(json['date']),
      ourTeamScore: parseNullableInt(seriesScore?['ourTeam']),
      opponentScore: parseNullableInt(seriesScore?['opponent']),
      venue: json['venue']?.toString(),
      overs: parseNullableInt(json['overs']),
      isHomeMatch: json['isHomeMatch'] is bool
          ? json['isHomeMatch'] as bool
          : (json['isHomeMatch']?.toString().toLowerCase() == 'true'),
      status: json['status']?.toString() ?? '',
      createdAt: parseDate(json['createdAt']),
      updatedAt: parseDate(json['updatedAt']),
    );
  }

  String vsText([String? ourTeamName]) {
    final left = (ourTeamName?.isNotEmpty ?? false) ? ourTeamName! : 'Our Team';
    return '$left vs $opponent';
  }

  String formattedDateLocal() {
    if (date == null) return '';
    final d = date!.toLocal();
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    final yyyy = d.year.toString();
    final hh = d.hour.toString().padLeft(2, '0');
    final min = d.minute.toString().padLeft(2, '0');
    return '$dd-$mm-$yyyy $hh:$min';
  }
}
