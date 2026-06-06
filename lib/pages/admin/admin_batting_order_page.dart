import 'package:flutter/material.dart';
import 'package:teamawesomesozeith/services/admin/admin_batting_order_service.dart';
import 'package:teamawesomesozeith/services/batting_order_service.dart';
import 'package:teamawesomesozeith/services/player_service.dart';
import 'package:teamawesomesozeith/utils/batting_order_calculator.dart';

class AdminBattingOrderPage extends StatefulWidget {
  const AdminBattingOrderPage({super.key});

  @override
  State<AdminBattingOrderPage> createState() => _AdminBattingOrderPageState();
}

class _AdminBattingOrderPageState extends State<AdminBattingOrderPage> {
  bool _loading = true;
  String? _error;

  List<String> _initialOrder = [];
  List<String> _newOrder = [];
  List<BattingOrderRow> _newOrderWithScores = [];
  List<PlayerLastFour> _playersLastFour = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await PlayerService.fetchPlayers(forceRefresh: true);
      _initialOrder = await BattingOrderService.fetchBattingOrder();
      _playersLastFour =
          BattingOrderCalculator.fromPlayersApi(PlayerService.players);
      _recalculate();
    } catch (e) {
      _error = e.toString();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _recalculate() {
    _newOrder = BattingOrderCalculator.calculateNewOrder(
      initialOrder: _initialOrder,
      playersLastFour: _playersLastFour,
    );
    _newOrderWithScores = BattingOrderCalculator.withScores(
      _newOrder,
      _playersLastFour,
    );
  }

  Future<void> _postOrder() async {
    if (!BattingOrderCalculator.areAllPlayersScoresComplete(_playersLastFour)) {
      _snack('Not all 11 players have 4 scores in last four matches.');
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Post new batting order?'),
        content: const Text(
          'This will replace the current batting order on the server.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Post')),
        ],
      ),
    );
    if (confirm != true) return;

    setState(() => _loading = true);
    try {
      await AdminBattingOrderService.saveOrder(_newOrder);
      _initialOrder = List<String>.from(_newOrder);
      _recalculate();
      _snack('Batting order posted successfully');
    } catch (e) {
      _snack('$e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  int _lastFourSum(String name) {
    final row = _playersLastFour.where(
      (p) => p.name.toLowerCase() == name.toLowerCase(),
    );
    if (row.isEmpty) return 0;
    return row.first.totalScore;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scoresComplete =
        BattingOrderCalculator.areAllPlayersScoresComplete(_playersLastFour);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Batting Order'),
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: _loading ? null : _load,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _loading && _initialOrder.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : _error != null && _initialOrder.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(_error!, textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        ElevatedButton(onPressed: _load, child: const Text('Retry')),
                      ],
                    ),
                  ),
                )
              : Stack(
                  children: [
                    ListView(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                      children: [
                        Text(
                          'Logic v${BattingOrderCalculator.logicVersion}: '
                          '1–5 top form | 6–8 old tail (backfill) | 9–11 remaining',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey[700],
                          ),
                        ),
                        if (!scoresComplete) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.orange.shade200),
                            ),
                            child: const Text(
                              'Warning: not all 11 players have 4 last-four scores. '
                              'Posting is blocked until scores are complete.',
                            ),
                          ),
                        ],
                        const SizedBox(height: 16),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final stacked = constraints.maxWidth < 600;
                            if (stacked) {
                              return Column(
                                children: [
                                  _OrderCard(
                                    title: 'Current order',
                                    names: _initialOrder,
                                    scoreFor: _lastFourSum,
                                  ),
                                  const SizedBox(height: 12),
                                  _OrderCard(
                                    title: 'Suggested new order',
                                    names: _newOrder,
                                    scores: _newOrderWithScores,
                                    showPosition: true,
                                  ),
                                ],
                              );
                            }
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: _OrderCard(
                                    title: 'Current order',
                                    names: _initialOrder,
                                    scoreFor: _lastFourSum,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _OrderCard(
                                    title: 'Suggested new order',
                                    names: _newOrder,
                                    scores: _newOrderWithScores,
                                    showPosition: true,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 20),
                        OutlinedButton.icon(
                          onPressed: _loading
                              ? null
                              : () {
                                  setState(_recalculate);
                                },
                          icon: const Icon(Icons.calculate_outlined),
                          label: const Text('Recalculate'),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: _loading || !scoresComplete ? null : _postOrder,
                          icon: const Icon(Icons.publish),
                          label: const Text('Post Batting Order'),
                        ),
                      ],
                    ),
                    if (_loading)
                      Container(
                        color: Colors.black26,
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                  ],
                ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final String title;
  final List<String> names;
  final List<BattingOrderRow>? scores;
  final bool showPosition;
  final int Function(String name)? scoreFor;

  const _OrderCard({
    required this.title,
    required this.names,
    this.scores,
    this.showPosition = false,
    this.scoreFor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            if (names.isEmpty)
              const Text('No batting order found', style: TextStyle(color: Colors.grey))
            else
              ...List.generate(names.length, (index) {
                final name = names[index];
                final score = scores != null
                    ? scores![index].totalScore
                    : scoreFor?.call(name);
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      if (showPosition) ...[
                        SizedBox(
                          width: 28,
                          child: Text(
                            '${index + 1}.',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                      Expanded(child: Text(name)),
                      if (score != null)
                        Text(
                          '$score',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                    ],
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}
