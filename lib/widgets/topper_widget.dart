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
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            colorScheme.primary,
            colorScheme.secondary.withOpacity(0.9),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withOpacity(0.28),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          // Profile Image with Border
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: colorScheme.onPrimary.withOpacity(0.7),
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.25),
                  blurRadius: 12,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 28,
              backgroundImage:
                  imagePath.isNotEmpty ? NetworkImage(imagePath) : null,
              backgroundColor: Colors.grey.shade200,
              child: imagePath.isEmpty
                  ? Icon(
                      Icons.person_rounded,
                      size: 30,
                      color: colorScheme.primary,
                    )
                  : null,
            ),
          ),
          const SizedBox(width: 14),
          // Player info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  playerName,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: colorScheme.onPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    if (runsScored != null)
                      _buildChip(
                        context,
                        icon: Icons.sports_cricket_rounded,
                        label: '${runsScored!} runs',
                      ),
                    if (runsScored != null && wicket != null)
                      const SizedBox(width: 8),
                    if (wicket != null)
                      _buildChip(
                        context,
                        icon: Icons.sports_baseball_rounded,
                        label: '$wicket wickets',
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChip(BuildContext context,
      {required IconData icon, required String label}) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colorScheme.onPrimary.withOpacity(0.18),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: colorScheme.onPrimary.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: colorScheme.onPrimary,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: colorScheme.onPrimary,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
