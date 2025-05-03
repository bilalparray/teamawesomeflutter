import 'package:flutter/material.dart';
import '../services/player_service.dart';
import '../widgets/custom_app_bar.dart';
import 'player_profile_page.dart';
import 'batting_order_page.dart'; // Destination for nav icon

class PlayersPage extends StatelessWidget {
  const PlayersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: CustomAppBar(
          title: const Text('Players'),
          // Pass actions through a row
          actions: [
            IconButton(
              icon: const Icon(
                  Icons.format_list_numbered), // icon for batting order
              tooltip: 'Batting Order',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const BattingOrderPage(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade50.withValues(alpha: 0.4),
              Colors.white.withValues(alpha: 0.9),
            ],
          ),
        ),
        child: const _PlayersContent(),
      ),
    );
  }
}

class _PlayersContent extends StatefulWidget {
  const _PlayersContent();

  @override
  State<_PlayersContent> createState() => _PlayersContentState();
}

class _PlayersContentState extends State<_PlayersContent> {
  late Future<void> _loadFuture;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadFuture = _loadPlayers();
  }

  Future<void> _loadPlayers() async {
    try {
      await PlayerService.fetchPlayers();
      if (PlayerService.players.isEmpty) _showError();
    } catch (_) {
      _showError();
    }
  }

  void _showError() => setState(() => _hasError = true);

  Future<void> _refreshData() async {
    if (mounted) {
      setState(() {
        _hasError = false;
        _loadFuture = _loadPlayers();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _loadFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(
              color: Colors.blue.shade800,
              strokeWidth: 3,
            ),
          );
        }

        if (_hasError || PlayerService.players.isEmpty) {
          return _ErrorWidget(onRetry: _refreshData);
        }

        return RefreshIndicator(
          color: Colors.blue.shade800,
          backgroundColor: Colors.white,
          onRefresh: _refreshData,
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            itemCount: PlayerService.players.length,
            itemBuilder: (ctx, i) {
              final player = PlayerService.players[i];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: PlayerCard(
                  name: player['name'] ?? 'Unknown Player',
                  role: player['role'] ?? 'Player',
                  imagePath: player['image']?.toString() ??
                      'assets/players/profile.png',
                  rank: _getPlayerRank(player),
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
        );
      },
    );
  }

  String _getPlayerRank(Map<String, dynamic> player) {
    final scores = player['scores'] as Map<String, dynamic>?;
    return scores?['career']?['ranking']?.toString() ?? '';
  }
}

class PlayerCard extends StatelessWidget {
  final String name;
  final String role;
  final String imagePath;
  final String rank;
  final VoidCallback onTap;

  const PlayerCard({
    super.key,
    required this.name,
    required this.role,
    required this.imagePath,
    required this.rank,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              _PlayerAvatar(imagePath: imagePath, rank: rank),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.blueGrey,
                      ),
                    ),
                    Text(
                      role.toUpperCase(),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 20, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlayerAvatar extends StatelessWidget {
  final String imagePath;
  final String rank;

  const _PlayerAvatar({required this.imagePath, required this.rank});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        CircleAvatar(
          radius: 28,
          backgroundImage: _getImageProvider(imagePath),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.amber.shade700,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            rank,
            style: const TextStyle(
                color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  ImageProvider _getImageProvider(String path) {
    if (path.startsWith('http')) return NetworkImage(path);
    if (path.startsWith('assets')) return AssetImage(path);
    return const AssetImage('assets/players/profile.png');
  }
}

class _ErrorWidget extends StatelessWidget {
  final VoidCallback onRetry;

  const _ErrorWidget({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: Colors.blueGrey.shade400),
          const SizedBox(height: 16),
          const Text(
            'Failed to load players',
            style: TextStyle(fontSize: 16, color: Colors.blueGrey),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: onRetry,
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }
}
