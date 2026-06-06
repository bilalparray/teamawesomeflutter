import 'package:flutter/material.dart';
import 'package:teamawesomesozeith/main.dart';
import 'package:teamawesomesozeith/models/mate_turn_model.dart';
import 'package:teamawesomesozeith/services/mate_turn_service.dart';
import 'package:teamawesomesozeith/widgets/upcoming_mate_turn_card.dart';

class MateTurnPage extends StatefulWidget {
  const MateTurnPage({super.key});

  @override
  State<MateTurnPage> createState() => _MateTurnPageState();
}

class _MateTurnPageState extends State<MateTurnPage> {
  bool _loading = true;
  String? _error;
  UpcomingMateTurn? _upcoming;

  @override
  void initState() {
    super.initState();
    _loadTurns();
  }

  Future<void> _loadTurns() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await MateTurnService.fetchAll(forceRefresh: true);
      if (!mounted) return;
      setState(() {
        _loading = false;
        _upcoming = MateTurnService.getUpcoming();
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString();
      });
      ApiErrorNotification().dispatch(context);
    }
  }

  bool _isSameDay(DateTime a, DateTime b) {
    final al = a.toLocal();
    final bl = b.toLocal();
    return al.year == bl.year && al.month == bl.month && al.day == bl.day;
  }

  List<MateTurnModel> _historyTurns() {
    final turns = MateTurnService.turns;
    final upcoming = _upcoming;
    if (upcoming == null || !upcoming.isRecorded) return turns;
    return turns
        .where((t) => !_isSameDay(t.date, upcoming.date))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final history = _historyTurns();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Mate Turn'),
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: RefreshIndicator(
        color: theme.primaryColor,
        onRefresh: _loadTurns,
        child: _loading
            ? ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 200),
                  Center(child: CircularProgressIndicator()),
                ],
              )
            : _error != null
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(24),
                    children: [
                      Icon(Icons.error_outline,
                          size: 48, color: theme.colorScheme.error),
                      const SizedBox(height: 12),
                      Text(
                        'Could not load mate turns',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _error!,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodySmall,
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: ElevatedButton.icon(
                          onPressed: _loadTurns,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Retry'),
                        ),
                      ),
                    ],
                  )
                : _upcoming == null && history.isEmpty
                    ? ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(24),
                        children: [
                          Icon(Icons.local_cafe_outlined,
                              size: 56, color: Colors.grey[400]),
                          const SizedBox(height: 12),
                          Text(
                            'No mate turns recorded yet',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      )
                    : ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                        children: [
                          if (_upcoming != null) ...[
                            UpcomingMateTurnCard(upcoming: _upcoming!),
                            if (history.isNotEmpty) ...[
                              const SizedBox(height: 20),
                              Text(
                                'History',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: Colors.grey[800],
                                ),
                              ),
                              const SizedBox(height: 10),
                            ],
                          ],
                          ...List.generate(history.length, (index) {
                            return Padding(
                              padding: EdgeInsets.only(
                                bottom: index < history.length - 1 ? 10 : 0,
                              ),
                              child: _MateTurnListTile(turn: history[index]),
                            );
                          }),
                        ],
                      ),
      ),
    );
  }
}

class _MateTurnListTile extends StatelessWidget {
  final MateTurnModel turn;

  const _MateTurnListTile({required this.turn});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
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
                  color: colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.calendar_today_rounded,
                  size: 20,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      turn.formattedDate(),
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      turn.playersLabel,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[800],
                            height: 1.35,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (turn.notes.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withOpacity(0.6),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.notes_rounded,
                      size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      turn.notes,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[700],
                            height: 1.4,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
