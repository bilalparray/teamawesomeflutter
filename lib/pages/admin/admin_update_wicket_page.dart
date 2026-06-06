import 'package:flutter/material.dart';
import 'package:teamawesomesozeith/services/admin/admin_player_service.dart';
import 'package:teamawesomesozeith/widgets/admin_player_dropdown.dart';

class AdminUpdateWicketPage extends StatefulWidget {
  const AdminUpdateWicketPage({super.key});

  @override
  State<AdminUpdateWicketPage> createState() => _AdminUpdateWicketPageState();
}

class _AdminUpdateWicketPageState extends State<AdminUpdateWicketPage> {
  bool _loading = true;
  bool _busy = false;
  String? _error;
  List<Map<String, dynamic>> _players = [];
  String? _playerId;
  final _wicket = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _wicket.dispose();
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
    final value = int.tryParse(_wicket.text.trim());
    if (value == null) {
      _snack('Enter a valid wicket count');
      return;
    }

    final name = _players
        .firstWhere((p) => p['_id']?.toString() == _playerId)['name']
        ?.toString();

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add wicket?'),
        content: Text('Add $value wicket(s) for $name?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Add')),
        ],
      ),
    );
    if (confirm != true) return;

    setState(() => _busy = true);
    try {
      await AdminPlayerService.addWicket(playerId: _playerId!, wicket: value);
      _snack('Wicket added');
      _wicket.clear();
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
        title: const Text('Update Wickets'),
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
                          controller: _wicket,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Wickets taken',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: _busy ? null : _submit,
                          icon: const Icon(Icons.sports),
                          label: const Text('Add Wicket'),
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
