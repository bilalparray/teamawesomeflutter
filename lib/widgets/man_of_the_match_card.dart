import 'dart:convert';
import 'package:flutter/material.dart';

class ManOfTheMatchCard extends StatelessWidget {
  final dynamic player;

  const ManOfTheMatchCard({super.key, required this.player});

  @override
  Widget build(BuildContext context) {
    final scores = player['scores'] as Map<String, dynamic>? ?? {};
    final runs = (scores['runs'] as List?)?.last?.toString() ?? '0';
    final wickets = (scores['wickets'] as List?)?.last?.toString() ?? '0';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Text(
                  '🌟 Man of the Match 🌟',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Colors.blue.shade800,
                    letterSpacing: 0.5,
                    shadows: [
                      Shadow(
                        color: Colors.blue.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(1, 1),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Profile Image with decorative border
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
                        radius: 40,
                        backgroundImage: player['image'] != null
                            ? _getImage(player['image'])
                            : const AssetImage('assets/players/profile.png'),
                        backgroundColor: Colors.grey.shade200,
                        child: player['image'] == null
                            ? Icon(Icons.person,
                                size: 40, color: Colors.blue.shade300)
                            : null,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            player['name'] ?? 'Unknown Player',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: Colors.blueGrey,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            (player['role'] ?? 'Player').toUpperCase(),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.blue.shade600,
                              letterSpacing: 0.8,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              _buildStatBadge('Runs', runs),
                              const SizedBox(width: 16),
                              _buildStatBadge('Wickets', wickets),
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
      ),
    );
  }

  Widget _buildStatBadge(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: '$label: ',
              style: TextStyle(
                color: Colors.blue.shade600,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            TextSpan(
              text: value,
              style: TextStyle(
                color: Colors.blue.shade800,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  ImageProvider _getImage(String imagePath) {
    return imagePath.isNotEmpty
        ? NetworkImage(imagePath)
        : const AssetImage('assets/players/profile.png');
  }
}
