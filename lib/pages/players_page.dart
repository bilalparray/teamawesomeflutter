import 'package:flutter/material.dart';
import 'package:teamawesomeflutter/widgets/player_list_card.dart';
import '../widgets/custom_app_bar.dart';
import 'player_profile_page.dart';

class PlayersPage extends StatelessWidget {
  PlayersPage({super.key});
  final List<Map<String, String>> players = [
    {
      'name': 'Rohit Sharma',
      'role': 'Top Scorer',
      'image': 'assets/players/batsman.png'
    },
    {
      'name': 'Jasprit Bumrah',
      'role': 'Leading Wicket-taker',
      'image': 'assets/players/profile.png'
    },
    {
      'name': 'Virat Kohli',
      'role': 'Captain',
      'image': 'assets/players/profile.png'
    },
    {
      'name': 'KL Rahul',
      'role': 'Wicket Keeper',
      'image': 'assets/players/profile.png'
    },
    {
      'name': 'Hardik Pandya',
      'role': 'All-Rounder',
      'image': 'assets/players/profile.png'
    },
    {
      'name': 'Ravindra Jadeja',
      'role': 'All-Rounder',
      'image': 'assets/players/profile.png'
    },
    {
      'name': 'Shubman Gill',
      'role': 'Opening Batsman',
      'image': 'assets/players/profile.png'
    },
    {
      'name': 'Mohammed Shami',
      'role': 'Fast Bowler',
      'image': 'assets/players/profile.png'
    },
    {
      'name': 'Kuldeep Yadav',
      'role': 'Spinner',
      'image': 'assets/players/profile.png'
    },
    {
      'name': 'Suryakumar Yadav',
      'role': 'Middle Order Batsman',
      'image': 'assets/players/profile.png'
    },
    {
      'name': 'Shardul Thakur',
      'role': 'Bowling All-Rounder',
      'image': 'assets/players/profile.png'
    }

    // add more here...
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: Text('Players')),
      body: ListView.builder(
        padding: const EdgeInsets.only(top: 16, bottom: 80, left: 8, right: 8),
        itemCount: players.length,
        itemBuilder: (ctx, i) {
          final p = players[i];
          return PlayerListCard(
            name: p['name']!,
            role: p['role']!,
            imagePath: p['image']!,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PlayerProfilePage(player: p),
              ),
            ),
          );
        },
      ),
    );
  }
}
