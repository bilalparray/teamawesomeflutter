import 'package:flutter/material.dart';
import 'package:teamawesomesozeith/pages/player_profile_page.dart';
import 'package:teamawesomesozeith/widgets/custom_app_bar.dart';
import '../services/batting_order_service.dart';
import '../services/player_service.dart';

class BattingOrderPage extends StatefulWidget {
  const BattingOrderPage({super.key});

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
    // Step 1: fetch batting order
    final battingOrder = await BattingOrderService.fetchBattingOrder();

    // Step 2: fetch players if not already fetched
    await PlayerService.fetchPlayers();

    final List<_PlayerWithScores> players = [];

    for (final playerName in battingOrder) {
      final player = PlayerService.players.firstWhere(
        (p) => p['name'].toString().toLowerCase() == playerName.toLowerCase(),
        orElse: () => null,
      );

      List<int> lastFourRuns = [];

      if (player != null) {
        final scores = player['scores'];
        if (scores != null && scores['runs'] != null) {
          final runsList = List<String>.from(scores['lastfour']);
          lastFourRuns = runsList.reversed
              .take(4)
              .map((e) => int.tryParse(e) ?? 0)
              .toList();
        }
      }

      players.add(
          _PlayerWithScores(name: playerName, lastFourScores: lastFourRuns));
    }

    return players;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: Text('Batting Order')),
      body: FutureBuilder<List<_PlayerWithScores>>(
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
              itemCount: players.length,
              itemBuilder: (context, index) {
                final player = players[index];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.blueAccent,
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(
                          color: Colors.white, // 👈 text color white
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      player.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    subtitle: player.lastFourScores.isNotEmpty
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  'Last 4 runs: ${player.lastFourScores.join(", ")}'),
                              const SizedBox(height: 4),
                              Text(
                                'Total of last 4: ${player.lastFourScores.reduce((a, b) => a + b)}',
                                style: const TextStyle(color: Colors.black54),
                              ),
                            ],
                          )
                        : const Text('No recent runs data'),
                    trailing:
                        const Icon(Icons.arrow_forward_ios_rounded, size: 20),
                    onTap: () {
                      // Find the full player object
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
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}

class _PlayerWithScores {
  final String name;
  final List<int> lastFourScores;

  _PlayerWithScores({required this.name, required this.lastFourScores});
}
