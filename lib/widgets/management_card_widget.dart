import 'package:flutter/material.dart';

class ManagementCardWidget extends StatelessWidget {
  final String imagePath;
  final String title;
  final String role;

  const ManagementCardWidget({
    super.key,
    required this.imagePath,
    required this.title,
    required this.role,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Row(
          children: [
            // Image
            CircleAvatar(
              radius: 40,
              // backgroundImage: AssetImage(imagePath),
              backgroundImage: NetworkImage(imagePath),
              backgroundColor: Colors.grey.shade200,
            ),
            const SizedBox(width: 16),
            // Name and Role
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    role,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
