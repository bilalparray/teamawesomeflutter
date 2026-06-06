class MateTurnPlayer {
  final String playerId;
  final String name;
  final String role;
  final int? fromGroupNumber;

  const MateTurnPlayer({
    required this.playerId,
    required this.name,
    required this.role,
    this.fromGroupNumber,
  });

  factory MateTurnPlayer.fromJson(Map<String, dynamic> json) {
    return MateTurnPlayer(
      playerId: json['playerId']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      role: json['role']?.toString() ?? 'regular',
      fromGroupNumber: _parseInt(json['fromGroupNumber']),
    );
  }

  static int? _parseInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    return int.tryParse(v.toString());
  }
}

class MateTurnModel {
  final String id;
  final DateTime date;
  final int groupNumber;
  final List<MateTurnPlayer> players;
  final String notes;

  const MateTurnModel({
    required this.id,
    required this.date,
    required this.groupNumber,
    required this.players,
    this.notes = '',
  });

  factory MateTurnModel.fromJson(Map<String, dynamic> json) {
    final rawPlayers = json['players'];
    final players = rawPlayers is List
        ? rawPlayers
            .whereType<Map>()
            .map((e) => MateTurnPlayer.fromJson(Map<String, dynamic>.from(e)))
            .toList()
        : <MateTurnPlayer>[];

    return MateTurnModel(
      id: json['_id']?.toString() ?? '',
      date: _parseDate(json['date']) ?? DateTime.now(),
      groupNumber: MateTurnPlayer._parseInt(json['groupNumber']) ?? 0,
      players: players,
      notes: json['notes']?.toString() ?? '',
    );
  }

  static DateTime? _parseDate(dynamic v) {
    if (v == null) return null;
    try {
      return DateTime.parse(v.toString());
    } catch (_) {
      return null;
    }
  }

  String get playersLabel {
    if (groupNumber == 6) {
      final solo = players.where((p) => p.role == 'solo').firstOrNull;
      final helper = players.where((p) => p.role == 'helper').firstOrNull;
      final soloName = solo?.name ?? '—';
      if (helper != null) {
        return '$soloName (helped by ${helper.name})';
      }
      return soloName;
    }
    return players.map((p) => p.name).join(' & ');
  }

  String formattedDate() => MateTurnModel.formatDate(date);

  static String formatDate(DateTime date) {
    final local = date.toLocal();
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final weekday = weekdays[local.weekday - 1];
    return '$weekday, ${local.day} ${months[local.month - 1]} ${local.year}';
  }
}

class MateTurnSuggested {
  final int suggestedGroupNumber;
  final DateTime suggestedDate;
  final List<String> playerNames;
  final String? note;

  const MateTurnSuggested({
    required this.suggestedGroupNumber,
    required this.suggestedDate,
    required this.playerNames,
    this.note,
  });

  factory MateTurnSuggested.fromJson(Map<String, dynamic> json) {
    final group = json['group'];
    List<String> names = [];
    if (group is Map && group['playerNames'] is List) {
      names = (group['playerNames'] as List)
          .map((e) => e.toString())
          .where((e) => e.isNotEmpty)
          .toList();
    }

    return MateTurnSuggested(
      suggestedGroupNumber:
          MateTurnPlayer._parseInt(json['suggestedGroupNumber']) ?? 0,
      suggestedDate:
          MateTurnModel._parseDate(json['suggestedDate']) ?? DateTime.now(),
      playerNames: names,
      note: json['note']?.toString(),
    );
  }

  String get playersLabel {
    if (suggestedGroupNumber == 6) {
      final solo = playerNames.isNotEmpty ? playerNames.first : '—';
      return '$solo (+ helper from Groups 1–5)';
    }
    if (playerNames.isEmpty) return '—';
    return playerNames.join(' & ');
  }

  String formattedDate() => MateTurnModel.formatDate(suggestedDate);
}

extension _FirstOrNull<E> on Iterable<E> {
  E? get firstOrNull {
    final it = iterator;
    if (!it.moveNext()) return null;
    return it.current;
  }
}
