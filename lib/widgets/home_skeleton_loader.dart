import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class HomeSkeletonLoader extends StatelessWidget {
  const HomeSkeletonLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: ListView(
        padding: const EdgeInsets.only(bottom: 80),
        children: [
          // Hero header skeleton
          Container(
            margin: const EdgeInsets.all(16),
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          // Space for Man of the Match card
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            height: 140,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          // Featured Players label
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            height: 24,
            width: 150,
            color: Colors.white,
          ),
          // Horizontal list skeleton
          SizedBox(
            height: 180,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: 3,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (_, __) => Container(
                width: 140,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
