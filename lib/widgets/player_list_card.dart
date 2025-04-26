// player_list_card.dart
import 'dart:convert';

import 'package:flutter/material.dart';

class PlayerListCard extends StatelessWidget {
  final String name;
  final String role;
  final String imagePath;
  final VoidCallback onTap;

  const PlayerListCard({
    required this.name,
    required this.role,
    required this.imagePath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Profile Picture
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: _getImageProvider(imagePath),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Name and Role
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      role,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              // Navigation Icon
              Icon(
                Icons.chevron_right,
                color: Colors.grey[400],
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }

  ImageProvider _getImageProvider(String imagePath) {
    if (imagePath.startsWith('data:image')) {
      // Handle base64 image
      try {
        final base64String = imagePath.split(',').last;
        return MemoryImage(base64Decode(base64String));
      } catch (e) {
        return const AssetImage('assets/players/profile.png');
      }
    } else {
      // Handle asset path
      return AssetImage(imagePath);
    }
  }
}
