import 'package:flutter/material.dart';
import 'package:teamawesomesozeith/services/admin/admin_player_service.dart';
import 'package:teamawesomesozeith/widgets/admin_player_dropdown.dart';

class AdminUpdateLastPage extends StatefulWidget {
  const AdminUpdateLastPage({super.key});

  @override
  State<AdminUpdateLastPage> createState() => _AdminUpdateLastPageState();
}

class _AdminUpdateLastPageState extends State<AdminUpdateLastPage> {
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

    final runs = _runs.text.trim().isEmpty ? null : int.tryParse(_runs.text.trim());
    final balls = _balls.text.trim().isEmpty ? null : int.tryParse(_balls.text.trim());
    final wickets =
        _wickets.text.trim().isEmpty ? null : int.tryParse(_wickets.text.trim());

    if (runs == null && balls == null && wickets == null) {
      _snack('Enter at least one field to update');
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Update last innings?'),
        content: Text(
          [
            if (runs != null) 'Runs: $runs',
            if (balls != null) 'Balls: $balls',
            if (wickets != null) 'Wickets: $wickets',
          ].join('\n'),
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
      await AdminPlayerService.updateLast(
        playerId: _playerId!,
        runs: runs,
        balls: balls,
        wickets: wickets,
      );
      _snack('Last slot updated');
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
        title: const Text('Update Last Slot'),
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
                        Text(
                          'Overwrite the most recent runs/balls/wickets entry for a player.',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 16),
                        AdminPlayerDropdown(
                          players: _players,
                          value: _playerId,
                          onChanged: (v) => setState(() => _playerId = v),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _runs,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Runs (optional)',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _balls,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Balls (optional)',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _wickets,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Wickets (optional)',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: _busy ? null : _submit,
                          icon: const Icon(Icons.edit),
                          label: const Text('Update Last Entry'),
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
