// lib/widgets/match_card.dart
import 'package:flutter/material.dart';
import '../models/match_model.dart';

class MatchCard extends StatelessWidget {
  final MatchModel match;

  const MatchCard({Key? key, required this.match}) : super(key: key);

  Color _statusColor(BuildContext context) {
    final s = match.status.toLowerCase();
    if (s.contains('upcom') || s.contains('upcoming')) {
      return Colors.orange.shade700;
    }
    if (s.contains('live')) return Colors.red.shade600;
    if (s.contains('completed') ||
        s.contains('finished') ||
        s.contains('done')) {
      return Colors.green.shade600;
    }
    return Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.12);
  }

  String _homeAwayLabel() => match.isHomeMatch ? 'Home' : 'Away';

  @override
  Widget build(BuildContext context) {
    final opponent = match.opponent.isNotEmpty ? match.opponent : 'Opponent';
    final dateText = match.formattedDateLocal();
    final scoreText =
        (match.ourTeamScore != null || match.opponentScore != null)
            ? '${match.ourTeamScore ?? 0} - ${match.opponentScore ?? 0}'
            : null;

    final opponentStyle = Theme.of(context).textTheme.titleLarge?.copyWith(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        );

    return Card(
      elevation: 6,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Opponent name prominent + status badge on the right
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(opponent,
                    style: opponentStyle, overflow: TextOverflow.ellipsis),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _statusColor(context).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  match.status.toUpperCase(),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: _statusColor(context),
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Quick info chips: date, home/away, overs, series flag
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              if (dateText.isNotEmpty)
                Chip(
                  label: Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.calendar_today, size: 14),
                    const SizedBox(width: 6),
                    Text(dateText),
                  ]),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              Chip(
                label: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(match.isHomeMatch ? Icons.home : Icons.flight, size: 14),
                  const SizedBox(width: 6),
                  Text(_homeAwayLabel()),
                ]),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              if (match.overs != null)
                Chip(
                  label: Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.av_timer, size: 14),
                    const SizedBox(width: 6),
                    Text('${match.overs} overs'),
                  ]),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              Chip(
                label: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(
                      match.isSeries
                          ? Icons.emoji_events
                          : Icons.sports_cricket,
                      size: 14),
                  const SizedBox(width: 6),
                  Text(match.isSeries ? 'Series' : 'Single Match'),
                ]),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              if (scoreText != null)
                Chip(
                  label: Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.score, size: 14),
                    const SizedBox(width: 6),
                    Text('Series: $scoreText'),
                  ]),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
            ],
          ),

          const SizedBox(height: 12),
          if ((match.venue ?? '').isNotEmpty)
            Row(children: [
              const Icon(Icons.location_on, size: 16),
              const SizedBox(width: 6),
              Expanded(
                  child: Text(match.venue!,
                      style: Theme.of(context).textTheme.bodySmall)),
            ]),

          // Divider & meta
          const SizedBox(height: 12),
          const Divider(height: 1, thickness: 0.5),
          const SizedBox(height: 8),
        ]),
      ),
    );
  }
}
