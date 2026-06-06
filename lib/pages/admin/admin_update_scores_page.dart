import 'package:flutter/material.dart';
import 'package:teamawesomesozeith/services/admin/admin_player_service.dart';
import 'package:teamawesomesozeith/widgets/admin_player_dropdown.dart';

class AdminUpdateScoresPage extends StatefulWidget {
  const AdminUpdateScoresPage({super.key});

  @override
  State<AdminUpdateScoresPage> createState() => _AdminUpdateScoresPageState();
}

class _AdminUpdateScoresPageState extends State<AdminUpdateScoresPage> {
  bool _loading = true;
  bool _busy = false;
  String? _error;
  List<Map<String, dynamic>> _players = [];
  String? _playerId;
  final _runs = TextEditingController();
  final _balls = TextEditingController();
  final _wickets = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _runs.dispose();
    _balls.dispose();
    _wickets.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      _players = await AdminPlayerService.fetchPlayers();
    } catch (e) {
      _error = e.toString();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _submit() async {
    if (_playerId == null) {
      _snack('Select a player');
      return;
    }

    final runs = AdminPlayerService.parseCommaNumbers(_runs.text);
    final balls = AdminPlayerService.parseCommaNumbers(_balls.text);
    final wickets = AdminPlayerService.parseCommaNumbers(_wickets.text);

    if (runs.isEmpty && balls.isEmpty && wickets.isEmpty) {
      _snack('Enter at least runs, balls, or wickets');
      return;
    }
    if (runs.isEmpty || balls.isEmpty || wickets.isEmpty) {
      _snack('Provide runs, balls, and wickets (comma-separated for multiple)');
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Append scores?'),
        content: Text(
          'Runs: $runs\nBalls: $balls\nWickets: $wickets\n\nThese will be appended to the player history.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Update')),
        ],
      ),
    );
    if (confirm != true) return;

    setState(() => _busy = true);
    try {
      await AdminPlayerService.appendScores(
        playerId: _playerId!,
        runs: runs,
        balls: balls,
        wickets: wickets,
      );
      _snack('Scores updated');
      _runs.clear();
      _balls.clear();
      _wickets.clear();
    } catch (e) {
      _snack('$e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Runs'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : Stack(
                  children: [
                    ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        AdminPlayerDropdown(
                          players: _players,
                          value: _playerId,
                          onChanged: (v) => setState(() => _playerId = v),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _runs,
                          keyboardType: TextInputType.text,
                          decoration: const InputDecoration(
                            labelText: 'Runs',
                            hintText: 'e.g. 25 or 12,15',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _balls,
                          keyboardType: TextInputType.text,
                          decoration: const InputDecoration(
                            labelText: 'Balls',
                            hintText: 'e.g. 18 or 10,12',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _wickets,
                          keyboardType: TextInputType.text,
                          decoration: const InputDecoration(
                            labelText: 'Wickets',
                            hintText: 'e.g. 2 or 0,1',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Use commas to append multiple innings at once.',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: _busy ? null : _submit,
                          icon: const Icon(Icons.save),
                          label: const Text('Update Score'),
                        ),
                      ],
                    ),
                    if (_busy)
                      const ColoredBox(
                        color: Colors.black26,
                        child: Center(child: CircularProgressIndicator()),
                      ),
                  ],
                ),
    );
  }
}
