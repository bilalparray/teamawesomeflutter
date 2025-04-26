// home_page.dart
import 'package:flutter/material.dart';
import '../services/player_service.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/player_card.dart';
import 'player_profile_page.dart';
import 'settings_page.dart';
import 'dart:convert'; // Add this import

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      await PlayerService.fetchPlayers();
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: const Text('Team Awesome Sozeith'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => SettingsPage()),
            ),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(child: Text(errorMessage))
              : _buildPlayerContent(),
    );
  }

  Widget _buildPlayerContent() {
    final players = PlayerService.players;
    final motm = PlayerService.manOfTheMatch;

    return ListView(
      padding: const EdgeInsets.only(bottom: 80),
      children: [
        // Hero header
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Play with Passion',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Welcome back, Captain! Check your squad\'s performance.',
                style: TextStyle(fontSize: 16, color: Colors.black87),
              ),
            ],
          ),
        ),

        // Man of the Match
        if (motm != null) _buildManOfTheMatchCard(motm),

        // Featured players
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Featured Players',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        SizedBox(
          height: 250,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 12),
            scrollDirection: Axis.horizontal,
            itemCount: players.length,
            itemBuilder: (ctx, i) {
              final player = players[i];
              return SizedBox(
                width: 200,
                child: PlayerCard(
                  name: player['name'] ?? 'Unknown Player',
                  role: player['role'] ?? 'Player',
                  imagePath: player['image'] != null
                      ? 'data:image/jpeg;base64,${player['image']}'
                      : 'assets/players/profile.png',
                  stats: _getPlayerStats(player),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => PlayerProfilePage(player: player)),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildManOfTheMatchCard(dynamic player) {
    final scores = player['scores'];
    final runs = scores['runs']?.last ?? '0';
    final wickets = scores['wickets']?.last ?? '0';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Text(
                '🌟 Man of the Match 🌟',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.amber,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: player['image'] != null
                        ? MemoryImage(base64Decode(player['image']
                            .split(',')
                            .last)) // Fixed base64 decode
                        : const AssetImage('assets/players/profile.png')
                            as ImageProvider,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          player['name'] ?? 'Unknown Player',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          player['role'] ?? 'Player',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text(
                              'Runs: $runs',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: 16),
                            Text(
                              'Wickets: $wickets',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getPlayerStats(Map<String, dynamic> player) {
    if (player['scores'] == null) return '';

    final scores = player['scores'];
    if (scores['career'] != null && scores['career']['ranking'] != null) {
      return 'Rank: ${scores['career']['ranking']}';
    }
    if (scores['runs'] != null && scores['runs'].isNotEmpty) {
      return 'Runs: ${scores['runs'].last}';
    }
    if (scores['wickets'] != null && scores['wickets'].isNotEmpty) {
      return 'Wickets: ${scores['wickets'].last}';
    }
    return '';
  }
}
