import 'package:flutter/material.dart';
import 'package:teamawesomesozeith/main.dart';
import '../services/player_service.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/player_list_card.dart';
import 'player_profile_page.dart';

class PlayersPage extends StatelessWidget {
  const PlayersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: Text('Players')),
      body: _PlayersContent(),
    );
  }
}

class _PlayersContent extends StatefulWidget {
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
      if (PlayerService.players.isEmpty) {
        _showError();
      }
    } catch (e) {
      _showError();
    }
  }

  void _showError() {
    setState(() => _hasError = true);
    ApiErrorNotification().dispatch(context);
  }

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
          return const Center(child: CircularProgressIndicator());
        }

        if (_hasError || PlayerService.players.isEmpty) {
          return ApiErrorScreen(
            onRetry: _refreshData,
            message: 'No players found or failed to load',
          );
        }

        return RefreshIndicator(
          onRefresh: _refreshData,
          child: ListView.builder(
            padding:
                const EdgeInsets.only(top: 16, bottom: 80, left: 8, right: 8),
            itemCount: PlayerService.players.length,
            itemBuilder: (ctx, i) {
              final player = PlayerService.players[i];
              return PlayerListCard(
                name: player['name'] ?? 'Unknown Player',
                role: player['role'] ?? 'Player',
                imagePath: player['image'] != null
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
      },
    );
  }
}

// Add this to your ApiErrorScreen to support custom messages
class ApiErrorScreen extends StatelessWidget {
  final VoidCallback onRetry;
  final String message;

  const ApiErrorScreen({
    super.key,
    required this.onRetry,
    this.message = 'Failed to load data from server',
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 80, color: Colors.red[600]),
            const SizedBox(height: 20),
            Text(
              'Error Loading Data',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 15),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
