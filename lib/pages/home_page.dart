import 'package:flutter/material.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/player_card.dart';
import 'player_profile_page.dart';
import 'settings_page.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});
  final featuredPlayers = [
    {
      'name': 'Rohit Sharma',
      'role': 'Top Scorer',
      'image': 'assets/players/batsman.png',
      'runs': '648',
      'matches': '11',
    },
    {
      'name': 'Jasprit Bumrah',
      'role': 'Leading Wicket-taker',
      'image': 'assets/players/profile.png',
      'wickets': '28',
      'economy': '4.25',
    },
    {
      'name': 'Jasprit Bumrah',
      'role': 'Leading Wicket-taker',
      'image': 'assets/players/profile.png',
      'wickets': '28',
      'economy': '4.25',
    },
    {
      'name': 'Jasprit Bumrah',
      'role': 'Leading Wicket-taker',
      'image': 'assets/players/profile.png',
      'wickets': '28',
      'economy': '4.25',
    },
    {
      'name': 'Jasprit Bumrah',
      'role': 'Leading Wicket-taker',
      'image': 'assets/players/profile.png',
      'wickets': '28',
      'economy': '4.25',
    },
    // ... rest of the players
  ];

  final manOfTheMatch = {
    'name': 'Virat Kohli',
    'role': 'Captain',
    'image': 'assets/players/profile.png',
    'performance': '112 runs (98 balls)',
    'date': 'Match 23 • 15 Nov 2023',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: const Text('Team Awesome Sozeith'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, size: 28),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => SettingsPage()),
            ),
          ),
        ],
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          // Hero Section
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF006D77), Color(0xFF00A896)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Play with Passion',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Welcome back, Captain! Check your squad\'s performance.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.9),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),

          // Man of the Match Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(bottom: 12),
                  child: Text(
                    'Man of the Match',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF2D3142),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          image: DecorationImage(
                            image: AssetImage(manOfTheMatch['image']!),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.emoji_events_rounded,
                                    color: Color(0xFFFFD700), size: 20),
                                const SizedBox(width: 6),
                                Text(
                                  manOfTheMatch['name']!,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF2D3142),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              manOfTheMatch['performance']!,
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              manOfTheMatch['date']!,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Featured Players Section
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
            child: Text(
              'Featured Players',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.grey.shade800,
              ),
            ),
          ),
          SizedBox(
            height: 180, // Reduced height to prevent vertical overflow
            child: ListView.builder(
              padding: const EdgeInsets.only(left: 16),
              scrollDirection: Axis.horizontal,
              itemCount: featuredPlayers.length,
              itemBuilder: (ctx, i) {
                final player = featuredPlayers[i];
                return SizedBox(
                  // Using SizedBox for better performance
                  width: 130, // Reduced width to prevent horizontal overflow
                  child: PlayerCard(
                    name: player['name']!,
                    role: player['role']!,
                    imagePath: player['image']!,
                    stats: player.containsKey('runs')
                        ? '${player['runs']} Runs'
                        : player.containsKey('wickets')
                            ? '${player['wickets']} Wickets'
                            : null,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PlayerProfilePage(player: player),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
