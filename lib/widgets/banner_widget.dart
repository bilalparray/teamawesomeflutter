import 'package:flutter/material.dart';

class BannerWidget extends StatelessWidget {
  final String imagePath;
  final String title;
  final String subtitle;

  const BannerWidget({
    required this.imagePath,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Image.asset(imagePath, width: double.infinity, fit: BoxFit.cover),
        // Container(
        //   width: double.infinity,
        //   height: 200,
         
        // ),
        Positioned(
          left: 16,
          bottom: 16,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold)),
              Text(subtitle,
                  style: TextStyle(color: Colors.white70, fontSize: 16)),
            ],
          ),
        ),
      ],
    );
  }
}
