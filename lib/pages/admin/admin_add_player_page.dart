import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:teamawesomesozeith/services/admin/admin_player_service.dart';

class AdminAddPlayerPage extends StatefulWidget {
  const AdminAddPlayerPage({super.key});

  @override
  State<AdminAddPlayerPage> createState() => _AdminAddPlayerPageState();
}

class _AdminAddPlayerPageState extends State<AdminAddPlayerPage> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _role = TextEditingController();
  final _born = TextEditingController();
  final _birthplace = TextEditingController();
  final _batting = TextEditingController();
  final _bowling = TextEditingController();
  final _debut = TextEditingController();
  String? _imageBase64;
  String? _imageFileName;
  bool _busy = false;

  @override
  void dispose() {
    _name.dispose();
    _role.dispose();
    _born.dispose();
    _birthplace.dispose();
    _batting.dispose();
    _bowling.dispose();
    _debut.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;
    final file = result.files.first;
    final bytes = file.bytes;
    if (bytes == null || bytes.isEmpty) return;
    setState(() {
      _imageBase64 = base64Encode(Uint8List.fromList(bytes));
      _imageFileName = file.name;
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add player?'),
        content: Text('Create new player "${_name.text.trim()}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Add')),
        ],
      ),
    );
    if (confirm != true) return;

    setState(() => _busy = true);
    try {
      await AdminPlayerService.createPlayer(
        name: _name.text.trim(),
        role: _role.text.trim(),
        born: _born.text.trim(),
        birthplace: _birthplace.text.trim(),
        battingstyle: _batting.text.trim(),
        bowlingstyle: _bowling.text.trim(),
        debut: _debut.text.trim(),
        imageBase64: _imageBase64,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Player added successfully')),
      );
      _formKey.currentState!.reset();
      setState(() {
        _imageBase64 = null;
        _imageFileName = null;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Player'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                TextFormField(
                  controller: _name,
                  decoration: const InputDecoration(
                    labelText: 'Name *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Name is required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _role,
                  decoration: const InputDecoration(
                    labelText: 'Role *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Role is required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _born,
                  decoration: const InputDecoration(
                    labelText: 'Born',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _birthplace,
                  decoration: const InputDecoration(
                    labelText: 'Birthplace',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _batting,
                  decoration: const InputDecoration(
                    labelText: 'Batting style',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _bowling,
                  decoration: const InputDecoration(
                    labelText: 'Bowling style',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _debut,
                  decoration: const InputDecoration(
                    labelText: 'Debut',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: _busy ? null : _pickImage,
                  icon: const Icon(Icons.image),
                  label: Text(_imageFileName ?? 'Pick profile photo (optional)'),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: _busy ? null : _submit,
                  icon: const Icon(Icons.person_add),
                  label: const Text('Save Player'),
                ),
              ],
            ),
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
