import 'package:flutter/material.dart';
import 'package:teamawesomesozeith/models/mate_turn_model.dart';
import 'package:teamawesomesozeith/services/mate_turn_service.dart';

/// Warm accent palette — distinct from the app's green home sections.
abstract final class MateTurnHighlightColors {
  static const backgroundStart = Color(0xFFFFF8E1);
  static const backgroundEnd = Color(0xFFFFE0B2);
  static const accent = Color(0xFFE65100);
  static const accentLight = Color(0xFFFF9800);
  static const border = Color(0xFFFFCC80);
  static const innerSurface = Color(0xFFFFFBF5);
}

class HomeUpcomingMateTurnSection extends StatelessWidget {
  final UpcomingMateTurn upcoming;

  const HomeUpcomingMateTurnSection({super.key, required this.upcoming});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            MateTurnHighlightColors.backgroundStart,
            MateTurnHighlightColors.backgroundEnd,
          ],
        ),
        border: Border.all(color: MateTurnHighlightColors.border, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: MateTurnHighlightColors.accent.withOpacity(0.12),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            child: Container(
              height: 4,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
                gradient: LinearGradient(
                  colors: [
                    MateTurnHighlightColors.accent,
                    MateTurnHighlightColors.accentLight,
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: MateTurnHighlightColors.accent.withOpacity(0.14),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.local_cafe_rounded,
                        color: MateTurnHighlightColors.accent,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Upcoming Mate Turn',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: MateTurnHighlightColors.accent,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Who brings mate this Sunday.',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: const Color(0xFF8D6E63),
                                    ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                UpcomingMateTurnCard(
                  upcoming: upcoming,
                  highlighted: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class UpcomingMateTurnCard extends StatelessWidget {
  final UpcomingMateTurn upcoming;
  final bool highlighted;

  const UpcomingMateTurnCard({
    super.key,
    required this.upcoming,
    this.highlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final accent = highlighted
        ? MateTurnHighlightColors.accent
        : colorScheme.primary;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: highlighted ? MateTurnHighlightColors.innerSurface : null,
        gradient: highlighted
            ? null
            : LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  colorScheme.primary.withOpacity(0.12),
                  colorScheme.secondary.withOpacity(0.08),
                ],
              ),
        border: Border.all(
          color: highlighted
              ? MateTurnHighlightColors.border
              : colorScheme.primary.withOpacity(0.25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.local_cafe_rounded, color: accent),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  upcoming.isRecorded ? 'Upcoming Mate Turn' : 'Next Mate Turn',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: accent,
                      ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: accent.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  'Group ${upcoming.groupNumber}',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: accent,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            MateTurnModel.formatDate(upcoming.date),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: highlighted ? const Color(0xFF5D4037) : null,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            upcoming.playersLabel,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: highlighted
                      ? const Color(0xFF6D4C41)
                      : Colors.grey[800],
                  height: 1.35,
                ),
          ),
          if (upcoming.notes.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              upcoming.notes,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: highlighted
                        ? const Color(0xFF8D6E63)
                        : Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
            ),
          ],
        ],
      ),
    );
  }
}
