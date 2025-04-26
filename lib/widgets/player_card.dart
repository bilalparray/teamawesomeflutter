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
      margin: const EdgeInsets.only(right: 12, bottom: 8), // Adjusted margins
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10), // Reduced padding
          child: Column(
            mainAxisSize: MainAxisSize.min, // Prevents vertical overflow
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar with stats badge
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    width: double.infinity,
                    height: 100, // Fixed height for image container
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(
                        image: AssetImage(imagePath),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  if (stats != null)
                    Transform.translate(
                      offset: const Offset(4, 4), // Adjust badge position
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
                  fontSize: 14, // Reduced font size
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
                  fontSize: 12, // Reduced font size
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
}
