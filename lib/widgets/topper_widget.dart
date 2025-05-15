import 'package:flutter/material.dart';

class TopperCard extends StatelessWidget {
  final String imagePath;
  final String playerName;
  final int? runsScored;
  final int? wicket;

  const TopperCard({
    super.key,
    required this.imagePath,
    required this.playerName,
    this.runsScored,
    this.wicket,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white,
              Colors.blue.shade50,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Profile Image
            CircleAvatar(
              radius: 30,
              backgroundImage:
                  imagePath.isNotEmpty ? NetworkImage(imagePath) : null,
              backgroundColor: Colors.grey.shade200,
              child: imagePath.isEmpty
                  ? const Icon(Icons.person, size: 30, color: Colors.blue)
                  : null,
            ),
            const SizedBox(width: 16),

            // Name, Runs, and Wicket Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    playerName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (runsScored != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      'Runs: $runsScored',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.green.shade700,
                      ),
                    ),
                  ],
                  if (wicket != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Wickets: $wicket',
                      style: TextStyle(
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                        color: Colors.green.shade700,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
