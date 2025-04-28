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
        elevation: 4,
        color: const Color.fromARGB(255, 250, 248, 248),
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
                        ? _getImage(player['image'])
                        : const AssetImage('assets/players/profile.png'),
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

  ImageProvider _getImage(String path) {
    if (path.startsWith('data:image')) {
      // base64 data-URI
      return MemoryImage(base64Decode(path.split(',').last));
    } else if (path.startsWith('http://') || path.startsWith('https://')) {
      // network URL
      return NetworkImage(path);
    } else {
      // asset path
      return AssetImage(path);
    }
  }
}
