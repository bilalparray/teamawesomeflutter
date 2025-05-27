import 'package:flutter/material.dart';
import 'package:teamawesomesozeith/main.dart';
import 'package:teamawesomesozeith/pages/player_profile_page.dart';
import 'package:teamawesomesozeith/widgets/custom_app_bar.dart';
import '../services/batting_order_service.dart';
import '../services/player_service.dart';

class BattingOrderPage extends StatefulWidget {
  const BattingOrderPage({Key? key}) : super(key: key);

  @override
  State<BattingOrderPage> createState() => _BattingOrderPageState();
}

class _BattingOrderPageState extends State<BattingOrderPage> {
  late Future<List<_PlayerWithScores>> _battingOrderWithScores;

  @override
  void initState() {
    super.initState();
    _battingOrderWithScores = _fetchBattingOrderWithScores();
  }

  Future<List<_PlayerWithScores>> _fetchBattingOrderWithScores() async {
    try {
      final battingOrder = await BattingOrderService.fetchBattingOrder();
      await PlayerService.fetchPlayers();
      final List<_PlayerWithScores> players = [];

      for (final playerName in battingOrder) {
        final player = PlayerService.players.firstWhere(
          (p) => p['name'].toString().toLowerCase() == playerName.toLowerCase(),
          orElse: () => null,
        );

        List<int> lastFourRuns = [];
        if (player != null && player.isNotEmpty) {
          final scores = player['scores'] as Map<String, dynamic>? ?? {};
          final lastFour = scores['lastfour'] as List<dynamic>? ?? [];
          lastFourRuns = lastFour.reversed
              .take(4)
              .map((e) => int.tryParse(e.toString()) ?? 0)
              .toList();
        }

        players.add(
            _PlayerWithScores(name: playerName, lastFourScores: lastFourRuns));
      }

      return players;
    } catch (e) {
      ApiErrorNotification().dispatch(context);
      return [];
    }
  }

  Future<void> _onRefresh() async {
    final refreshed = await _fetchBattingOrderWithScores();
    setState(() {
      _battingOrderWithScores = Future.value(refreshed);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text('Batting Order'),
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: RefreshIndicator(
        color: Theme.of(context).primaryColor,
        onRefresh: _onRefresh,
        child: FutureBuilder<List<_PlayerWithScores>>(
          future: _battingOrderWithScores,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No batting order found'));
            } else {
              final players = snapshot.data!;
              return ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: players.length,
                itemBuilder: (context, index) {
                  final player = players[index];
                  final total = player.lastFourScores.isNotEmpty
                      ? player.lastFourScores.reduce((a, b) => a + b)
                      : 0;

                  return Card(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {
                        final fullPlayer = PlayerService.players.firstWhere(
                          (p) =>
                              p['name'].toString().toLowerCase() ==
                              player.name.toLowerCase(),
                          orElse: () => null,
                        );
                        if (fullPlayer != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  PlayerProfilePage(player: fullPlayer),
                            ),
                          );
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundColor: Theme.of(context).primaryColor,
                              child: Text(
                                '${index + 1}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    player.name,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Theme.of(context).primaryColorDark,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  if (player.lastFourScores.isNotEmpty) ...[
                                    Text(
                                      'Last 4 Matches: ${player.lastFourScores.join(', ')}',
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Total: $total',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xFFAB47BC),
                                      ),
                                    ),
                                  ] else ...[
                                    const Text(
                                      'No recent data',
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontStyle: FontStyle.italic),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            const Icon(Icons.arrow_forward_ios,
                                size: 20, color: Colors.grey),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}

class _PlayerWithScores {
  final String name;
  final List<int> lastFourScores;

  _PlayerWithScores({required this.name, required this.lastFourScores});
}
