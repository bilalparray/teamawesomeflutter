class PlayerLastFour {
  final String name;
  final List<num> lastfour;

  const PlayerLastFour({required this.name, required this.lastfour});

  int get totalScore => lastfour.fold(0, (a, b) => a + b.toInt());
}

class BattingOrderRow {
  final String name;
  final int totalScore;

  const BattingOrderRow({required this.name, required this.totalScore});
}

/// Mirrors web admin `battingorder.js` logic (v8).
class BattingOrderCalculator {
  static const logicVersion = 8;

  static List<String> calculateNewOrder({
    required List<String> initialOrder,
    required List<PlayerLastFour> playersLastFour,
  }) {
    if (initialOrder.isEmpty || playersLastFour.isEmpty) {
      return List<String>.from(initialOrder);
    }

    final sortedAll = _sortPlayersByLastFour(initialOrder, playersLastFour);
    final topFive = sortedAll.take(5).toList();
    final middleThree = _pickMiddleThreeFromPreviousOrder(
      initialOrder,
      topFive,
    );
    final middleSet = middleThree.toSet();
    final tailThree = initialOrder
        .where((p) => !topFive.contains(p) && !middleSet.contains(p))
        .toList();

    return [
      ...topFive.map((n) => _toDbPlayerName(n, playersLastFour)),
      ..._sortPlayersByLastFour(middleThree, playersLastFour)
          .map((n) => _toDbPlayerName(n, playersLastFour)),
      ..._sortPlayersByLastFour(tailThree, playersLastFour)
          .map((n) => _toDbPlayerName(n, playersLastFour)),
    ];
  }

  static List<BattingOrderRow> withScores(
    List<String> order,
    List<PlayerLastFour> playersLastFour,
  ) {
    return order.map((name) {
      final row = _findPlayerLastFour(name, playersLastFour);
      return BattingOrderRow(
        name: name,
        totalScore: row?.totalScore ?? 0,
      );
    }).toList();
  }

  static bool areAllPlayersScoresComplete(List<PlayerLastFour> playersLastFour) {
    return playersLastFour.length == 11 &&
        playersLastFour.every((p) => p.lastfour.length == 4);
  }

  static List<PlayerLastFour> fromPlayersApi(List<dynamic> players) {
    return players.map((player) {
      final map = player as Map<String, dynamic>;
      final scores = map['scores'] as Map<String, dynamic>? ?? {};
      final lastFourRaw = scores['lastfour'] as List<dynamic>? ?? [];
      final lastfour = lastFourRaw
          .map((s) => num.tryParse(s.toString()) ?? 0)
          .toList();
      return PlayerLastFour(
        name: map['name']?.toString() ?? '',
        lastfour: lastfour,
      );
    }).toList();
  }

  static List<String> _pickMiddleThreeFromPreviousOrder(
    List<String> initialOrder,
    List<String> topFive,
  ) {
    final topSet = topFive.toSet();
    final picked = <String>[];
    for (int i = initialOrder.length - 1; i >= 0 && picked.length < 3; i--) {
      final player = initialOrder[i];
      if (!topSet.contains(player) && !picked.contains(player)) {
        picked.add(player);
      }
    }
    return picked;
  }

  static List<String> _sortPlayersByLastFour(
    List<String> order,
    List<PlayerLastFour> playersLastFour,
  ) {
    final copy = List<String>.from(order);
    copy.sort((a, b) {
      final sumA = _getLastFourSum(a, playersLastFour);
      final sumB = _getLastFourSum(b, playersLastFour);
      return sumB.compareTo(sumA);
    });
    return copy;
  }

  static PlayerLastFour? _findPlayerLastFour(
    String playerName,
    List<PlayerLastFour> playersLastFour,
  ) {
    final key = playerName.toLowerCase().trim();
    for (final p in playersLastFour) {
      if (p.name.toLowerCase().trim() == key) return p;
    }
    return null;
  }

  static String _toDbPlayerName(
    String playerName,
    List<PlayerLastFour> playersLastFour,
  ) {
    final row = _findPlayerLastFour(playerName, playersLastFour);
    return row?.name ?? playerName;
  }

  static int _getLastFourSum(
    String playerName,
    List<PlayerLastFour> playersLastFour,
  ) {
    return _findPlayerLastFour(playerName, playersLastFour)?.totalScore ?? 0;
  }
}
