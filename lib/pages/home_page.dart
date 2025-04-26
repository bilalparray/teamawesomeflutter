// home_page.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart'; // ← shimmer import
import '../services/player_service.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/player_card.dart';
import 'player_profile_page.dart';
import 'settings_page.dart';

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
    setState(() => isLoading = true);
    try {
      await PlayerService.fetchPlayers();
      setState(() => isLoading = false);
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (errorMessage.isNotEmpty) {
      // Error state
      return Scaffold(
        appBar: CustomAppBar(title: const Text('Team Awesome Sozeith')),
        body: Center(child: Text(errorMessage)),
      );
    }

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
      body: isLoading ? _buildSkeletonLoader() : _buildPlayerContent(),
    );
  }

  Widget _buildSkeletonLoader() {
    // A simple shimmer skeleton for the whole page
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: ListView(
        padding: const EdgeInsets.only(bottom: 80),
        children: [
          // Hero header skeleton
          Container(
            margin: const EdgeInsets.all(16),
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          // Space for Man of the Match card
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            height: 140,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          // Featured Players label
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            height: 24,
            width: 150,
            color: Colors.white,
          ),
          // Horizontal list skeleton
          SizedBox(
            height: 180,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: 3,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (_, __) => Container(
                width: 140,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
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
        ),
      ],
    );
  }

  Widget _buildManOfTheMatchCard(dynamic player) {
    final scores = player['scores'] as Map<String, dynamic>? ?? {};
    final runs = (scores['runs'] as List?)?.last?.toString() ?? '0';
    final wickets = (scores['wickets'] as List?)?.last?.toString() ?? '0';

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
                        ? MemoryImage(
                            base64Decode(player['image'].toString()),
                          )
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
