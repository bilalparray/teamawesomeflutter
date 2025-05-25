import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart'; // for launchUrlString

class ManagementCardWidget extends StatelessWidget {
  final String imagePath;
  final String title;
  final String role;
  final String description;
  final String url;

  const ManagementCardWidget({
    super.key,
    required this.imagePath,
    required this.title,
    required this.role,
    required this.description,
    this.url = '',
  });

  Future<void> _launchURL() async {
    if (url.isEmpty) return;
    try {
      // Use launchUrlString for simpler handling
      await launchUrlString(
        url,
        mode: LaunchMode.platformDefault, // let system choose best app
      );
    } catch (e) {
      debugPrint('Could not launch "$url": $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
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
          child: Row(
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
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 40,
                  backgroundImage: AssetImage(imagePath),
                  backgroundColor: Colors.grey.shade200,
                  child: imagePath.isEmpty
                      ? const Icon(Icons.person, size: 40, color: Colors.blue)
                      : null,
                ),
              ),
              const SizedBox(width: 20),

              // Information Section
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Colors.blueGrey,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      role.toUpperCase(),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue.shade600,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 15,
                        height: 1.4,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),

              // Navigator Icon horizontally aligned at end
              IconButton(
                icon: const Icon(Icons.navigate_next),
                onPressed: _launchURL,
                tooltip: 'Open Link',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
