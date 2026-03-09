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
    final colorScheme = Theme.of(context).colorScheme;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                colorScheme.primary,
                colorScheme.secondary.withOpacity(0.9),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: colorScheme.primary.withOpacity(0.25),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Top row: rank chip
                Align(
                  alignment: Alignment.topRight,
                  child: rank.isNotEmpty
                      ? Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: colorScheme.onPrimary.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: colorScheme.onPrimary.withOpacity(0.4),
                            ),
                          ),
                          child: Text(
                            rank,
                            style: TextStyle(
                              color: colorScheme.onPrimary,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
                const SizedBox(height: 8),
                // Profile Image
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: colorScheme.onPrimary.withOpacity(0.4),
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.18),
                        blurRadius: 12,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 42,
                    backgroundImage: _getImageProvider(imagePath),
                    backgroundColor: Colors.grey.shade200,
                    child: imagePath.isEmpty
                        ? Icon(
                            Icons.person_rounded,
                            size: 40,
                            color: colorScheme.primary,
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 14),
                // Player Name
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: colorScheme.onPrimary,
                    letterSpacing: 0.4,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                // Role
                Text(
                  role.toUpperCase(),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onPrimary.withOpacity(0.78),
                    letterSpacing: 0.9,
                  ),
                ),
              ],
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
