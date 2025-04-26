// players_page.dart
import 'package:flutter/material.dart';
import '../services/player_service.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/player_list_card.dart';
import 'player_profile_page.dart';

class PlayersPage extends StatelessWidget {
  const PlayersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final players = PlayerService.players;

    return Scaffold(
      appBar: const CustomAppBar(title: Text('Players')),
      body: ListView.builder(
        padding: const EdgeInsets.only(top: 16, bottom: 80, left: 8, right: 8),
        itemCount: players.length,
        itemBuilder: (ctx, i) {
          final player = players[i];
          return PlayerListCard(
            name: player['name'] ?? 'Unknown Player',
            role: player['role'] ?? 'Player',
            imagePath:
                player['image'] != null && player['image'].toString().isNotEmpty
                    ? player['image'].toString()
                    : 'assets/players/profile.png',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PlayerProfilePage(player: player),
              ),
            ),
          );
        },
      ),
    );
  }
}
