import 'package:flutter/material.dart';
import 'package:teamawesomesozeith/pages/player_profile_page.dart';
import '../services/player_service.dart';

class FeaturedPlayersList extends StatelessWidget {
  const FeaturedPlayersList({super.key});

  @override
  Widget build(BuildContext context) {
    final players = PlayerService.players;

    return SizedBox(
      height: 250,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: players.length,
        itemBuilder: (ctx, i) {
          final p = players[i];
          return Padding(
            padding: const EdgeInsets.only(right: 16),
            child: SizedBox(
              width: 220,
              child: PlayerCard(
                name: p['name'] ?? 'Unknown Player',
                role: p['role'] ?? 'Player',
                imagePath: (p['image'] is String)
                    ? p['image'] as String
                    : 'assets/players/profile.png',
                rank: _getPlayerRank(p),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PlayerProfilePage(player: p),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  String _getPlayerRank(Map<String, dynamic> player) {
    final scores = player['scores'] as Map<String, dynamic>?;
    final career = scores?['career'] as Map?;
    return career?.containsKey('ranking') ?? false
        ? 'Rank ${career!['ranking']}'
        : '';
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
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Card(
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          shadowColor: Colors.blue.withOpacity(0.2),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white,
                  Colors.blue.shade50,
                ],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Profile Image with Rank Chip
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.blue.shade100,
                            width: 3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.withOpacity(0.1),
                              blurRadius: 8,
                              spreadRadius: 2,
                            )
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 50,
                          backgroundImage: _getImageProvider(imagePath),
                          backgroundColor: Colors.grey.shade200,
                          child: imagePath.isEmpty
                              ? Icon(Icons.person,
                                  size: 50, color: Colors.blue.shade300)
                              : null,
                        ),
                      ),
                      if (rank.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade800,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blue.withOpacity(0.2),
                                blurRadius: 4,
                                spreadRadius: 1,
                              )
                            ],
                          ),
                          child: Text(
                            rank,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Player Name
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Colors.blueGrey,
                      letterSpacing: 0.5,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  // Role
                  Text(
                    role.toUpperCase(),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue.shade600,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  ImageProvider _getImageProvider(String path) {
    if (path.startsWith('http')) return NetworkImage(path);
    if (path.startsWith('assets')) return AssetImage(path);
    return const AssetImage('assets/players/profile.png');
  }
}
