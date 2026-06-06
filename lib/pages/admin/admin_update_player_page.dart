import 'package:flutter/material.dart';
import 'package:teamawesomesozeith/services/admin/admin_player_service.dart';
import 'package:teamawesomesozeith/widgets/admin_player_dropdown.dart';

class AdminUpdatePlayerPage extends StatefulWidget {
  const AdminUpdatePlayerPage({super.key});

  @override
  State<AdminUpdatePlayerPage> createState() => _AdminUpdatePlayerPageState();
}

class _AdminUpdatePlayerPageState extends State<AdminUpdatePlayerPage> {
  bool _loading = true;
  bool _busy = false;
  String? _error;
  List<Map<String, dynamic>> _players = [];
  String? _playerId;

  final _name = TextEditingController();
  final _role = TextEditingController();
  final _born = TextEditingController();
  final _birthplace = TextEditingController();
  final _batting = TextEditingController();
  final _bowling = TextEditingController();
  final _debut = TextEditingController();
  final _image = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _name.dispose();
    _role.dispose();
    _born.dispose();
    _birthplace.dispose();
    _batting.dispose();
    _bowling.dispose();
    _debut.dispose();
    _image.dispose();
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

  Future<void> _onPlayerSelected(String? id) async {
    setState(() => _playerId = id);
    if (id == null) return;

    setState(() => _busy = true);
    try {
      final player = await AdminPlayerService.fetchPlayer(id);
      _name.text = player['name']?.toString() ?? '';
      _role.text = player['role']?.toString() ?? '';
      _born.text = player['born']?.toString() ?? '';
      _birthplace.text = player['birthplace']?.toString() ?? '';
      _batting.text = player['battingstyle']?.toString() ?? '';
      _bowling.text = player['bowlingstyle']?.toString() ?? '';
      _debut.text = player['debut']?.toString() ?? '';
      _image.text = player['image']?.toString() ?? '';
    } catch (e) {
      _snack('$e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _submit() async {
    if (_playerId == null) {
      _snack('Select a player');
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Update profile?'),
        content: Text('Save changes for "${_name.text.trim()}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Save')),
        ],
      ),
    );
    if (confirm != true) return;

    setState(() => _busy = true);
    try {
      await AdminPlayerService.updateProfile(
        playerId: _playerId!,
        fields: {
          'name': _name.text.trim(),
          'role': _role.text.trim(),
          'born': _born.text.trim(),
          'birthplace': _birthplace.text.trim(),
          'battingstyle': _batting.text.trim(),
          'bowlingstyle': _bowling.text.trim(),
          'debut': _debut.text.trim(),
          'image': _image.text.trim(),
        },
      );
      _snack('Profile updated');
      await _load();
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
        title: const Text('Update Player Profile'),
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
                          onChanged: _onPlayerSelected,
                        ),
                        const SizedBox(height: 16),
                        _field(_name, 'Name'),
                        _field(_role, 'Role'),
                        _field(_born, 'Born'),
                        _field(_birthplace, 'Birthplace'),
                        _field(_batting, 'Batting style'),
                        _field(_bowling, 'Bowling style'),
                        _field(_debut, 'Debut'),
                        TextField(
                          controller: _image,
                          maxLines: 3,
                          decoration: const InputDecoration(
                            labelText: 'Image (base64)',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: _busy ? null : _submit,
                          icon: const Icon(Icons.save),
                          label: const Text('Save Profile'),
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

  Widget _field(TextEditingController c, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: c,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}
