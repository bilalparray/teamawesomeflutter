import 'dart:convert';

import 'package:flutter/material.dart';

class PlayerCard extends StatelessWidget {
  final String name;
  final String role;
  final String imagePath;
  final String? stats;
  final VoidCallback onTap;

  const PlayerCard({
    super.key,
    required this.name,
    required this.role,
    required this.imagePath,
    required this.onTap,
    this.stats,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      elevation: 1,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar with stats badge
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    width: double.infinity,
                    height: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(
                        image: _getImage(imagePath), // Dynamic image handling
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  if (stats != null)
                    Transform.translate(
                      offset: const Offset(4, 4),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.green[700],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          stats!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              // Player info
              Text(
                name,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                role,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Function to get ImageProvider based on whether the path is base64 or asset
  ImageProvider _getImage(String path) {
    if (path.startsWith('data:image')) {
      // If it's base64 data, decode it and use MemoryImage
      return MemoryImage(base64Decode(path.split(',').last));
    } else {
      // Otherwise, it's an asset path or URL
      return AssetImage(path);
    }
  }
}
