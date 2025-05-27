import 'package:flutter/material.dart';

class TopperCard extends StatelessWidget {
  final String imagePath;
  final String playerName;
  final int? runsScored;
  final int? wicket;

  const TopperCard({
    Key? key,
    required this.imagePath,
    required this.playerName,
    this.runsScored,
    this.wicket,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color.fromARGB(255, 32, 109, 210),
              Color.fromARGB(255, 32, 109, 210),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          // border: Border.all(
          //   color: Colors.blue.shade100,
          //   width: 3,
          // ),
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Profile Image with Border
            Container(
              width: 64,
              height: 64,
              // padding: const EdgeInsets.all(3), // Space for the border
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.blue.shade100,
                  width: 3,
                ),
              ),
              child: CircleAvatar(
                radius: 28,
                backgroundImage:
                    imagePath.isNotEmpty ? NetworkImage(imagePath) : null,
                backgroundColor: Colors.grey.shade200,
                child: imagePath.isEmpty
                    ? const Icon(Icons.person, size: 30, color: Colors.blue)
                    : null,
              ),
            ),

            const SizedBox(width: 16),

            // Player info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    playerName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  if (runsScored != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      'Runs: $runsScored',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color.fromARGB(255, 225, 226, 225),
                      ),
                    ),
                  ],
                  if (wicket != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Wickets: $wicket',
                      style: const TextStyle(
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                        color: Color.fromARGB(255, 225, 226, 225),
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
