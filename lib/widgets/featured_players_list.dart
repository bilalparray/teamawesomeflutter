import 'package:flutter/material.dart';
import 'package:teamawesomesozeith/pages/player_profile_page.dart';
import '../services/player_service.dart';
import '../widgets/player_card.dart';

class FeaturedPlayersList extends StatelessWidget {
  const FeaturedPlayersList({super.key});

  @override
  Widget build(BuildContext context) {
    final players = PlayerService.players;

    return SizedBox(
      height: 250,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 12),
        scrollDirection: Axis.horizontal,
        itemCount: players.length,
        itemBuilder: (ctx, i) {
          final p = players[i];
          return SizedBox(
            width: 200,
            child: PlayerCard(
              name: p['name'] ?? 'Unknown Player',
              role: p['role'] ?? 'Player',
              imagePath: p['image'] != null
                  ? 'data:image/jpeg;base64,${p['image']}'
                  : 'assets/players/profile.png',
              stats: _getPlayerStats(p),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PlayerProfilePage(player: p),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  String _getPlayerStats(Map<String, dynamic> player) {
    final scores = player['scores'] as Map<String, dynamic>?;

    if (scores == null) return '';

    if (scores['career'] is Map &&
        (scores['career'] as Map).containsKey('ranking')) {
      return 'Rank: ${(scores['career'] as Map)['ranking']}';
    }
    if (scores['runs'] is List && (scores['runs'] as List).isNotEmpty) {
      return 'Runs: ${(scores['runs'] as List).last}';
    }
    if (scores['wickets'] is List && (scores['wickets'] as List).isNotEmpty) {
      return 'Wickets: ${(scores['wickets'] as List).last}';
    }
    return '';
  }
}
