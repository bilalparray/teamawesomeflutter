import 'package:flutter/material.dart';
import 'package:teamawesomesozeith/models/mate_turn_model.dart';
import 'package:teamawesomesozeith/services/admin/admin_mate_turn_service.dart';
import 'package:teamawesomesozeith/services/player_service.dart';

class AdminMateTurnPage extends StatefulWidget {
  const AdminMateTurnPage({super.key});

  @override
  State<AdminMateTurnPage> createState() => _AdminMateTurnPageState();
}

class _AdminMateTurnPageState extends State<AdminMateTurnPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;
  bool _loading = true;
  String? _error;

  List<dynamic> _players = [];
  List<MateGroupEntry> _groups = [];
  List<MateTurnModel> _turns = [];
  MateTurnSuggested? _suggested;
  Map<String, int> _playerGroupMap = {};

  // Group form state: groupNumber -> list of selected player ids
  final Map<int, List<String?>> _groupSelections = {
    for (int i = 1; i <= 6; i++) i: i == 6 ? [null] : [null, null],
  };

  // Record form
  String? _editingTurnId;
  DateTime _turnDate = DateTime.now();
  int? _turnGroup;
  String? _player1Id;
  String? _player2Id;
  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
    _loadAll();
  }

  @override
  void dispose() {
    _tabs.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadAll() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await PlayerService.fetchPlayers(forceRefresh: true);
      _players = PlayerService.players;
      _groups = await AdminMateTurnService.fetchGroups();
      _turns = await AdminMateTurnService.fetchTurns();
      _suggested = await AdminMateTurnService.fetchSuggested();
      _syncGroupSelectionsFromApi();
      _applySuggestionToForm();
    } catch (e) {
      _error = e.toString();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _syncGroupSelectionsFromApi() {
    for (final g in _groups) {
      final ids = g.playerIds.map((e) => e.toString()).toList();
      final count = g.groupNumber == 6 ? 1 : 2;
      _groupSelections[g.groupNumber] = List<String?>.generate(
        count,
        (i) => i < ids.length ? ids[i] : null,
      );
    }
    _rebuildPlayerGroupMap();
  }

  void _rebuildPlayerGroupMap() {
    final byPlayerId = <String, int>{};
    for (final entry in _groupSelections.entries) {
      for (final id in entry.value) {
        if (id != null) byPlayerId[id] = entry.key;
      }
    }
    _playerGroupMap = byPlayerId;
  }

  void _applySuggestionToForm() {
    if (_editingTurnId != null) return;
    final s = _suggested;
    if (s == null) return;
    _turnDate = s.suggestedDate.toLocal();
    _turnGroup = s.suggestedGroupNumber;
    _onGroupChanged(resetPlayers: true);
  }

  String _playerName(String? id) {
    if (id == null) return '';
    final p = _players.cast<Map<String, dynamic>?>().firstWhere(
          (p) => p?['_id']?.toString() == id,
          orElse: () => null,
        );
    return p?['name']?.toString() ?? '';
  }

  List<Map<String, dynamic>> _playersForDropdown() {
    return _players.cast<Map<String, dynamic>>();
  }

  Future<void> _saveGroups() async {
    final payload = <Map<String, dynamic>>[];
    for (int n = 1; n <= 6; n++) {
      final ids = (_groupSelections[n] ?? []).whereType<String>().toList();
      final expected = n == 6 ? 1 : 2;
      if (ids.length != expected) {
        _snack('Group $n needs $expected player(s)');
        return;
      }
      payload.add({'groupNumber': n, 'playerIds': ids});
    }

    setState(() => _loading = true);
    try {
      await AdminMateTurnService.saveGroups(payload);
      _groups = await AdminMateTurnService.fetchGroups();
      _rebuildPlayerGroupMap();
      _snack('Groups saved');
    } catch (e) {
      _snack('$e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _onGroupChanged({bool resetPlayers = false}) {
    final gn = _turnGroup;
    if (gn == null) return;

    final group = _groups.firstWhere(
      (g) => g.groupNumber == gn,
      orElse: () =>
          MateGroupEntry(groupNumber: gn, playerIds: [], playerNames: []),
    );
    final ids = group.playerIds.map((e) => e.toString()).toList();

    if (gn == 6) {
      _player1Id = ids.isNotEmpty ? ids.first : null;
      if (resetPlayers) _player2Id = null;
    } else {
      if (resetPlayers) {
        _player1Id = ids.isNotEmpty ? ids[0] : null;
        _player2Id = ids.length > 1 ? ids[1] : null;
      }
    }
    setState(() {});
  }

  List<Map<String, dynamic>> _helperCandidates() {
    return _players.cast<Map<String, dynamic>>().where((p) {
      final id = p['_id']?.toString();
      if (id == _player1Id) return false;
      final g = _playerGroupMap[id];
      return g != null && g >= 1 && g <= 5;
    }).toList();
  }

  List<Map<String, dynamic>> _playersInGroup(int gn) {
    final group = _groups.firstWhere(
      (g) => g.groupNumber == gn,
      orElse: () =>
          MateGroupEntry(groupNumber: gn, playerIds: [], playerNames: []),
    );
    final allowed = group.playerIds.map((e) => e.toString()).toSet();
    return _players.cast<Map<String, dynamic>>().where((p) {
      return allowed.contains(p['_id']?.toString());
    }).toList();
  }

  Map<String, dynamic> _buildTurnBody() {
    final gn = _turnGroup!;
    final p1Name = _playerName(_player1Id);
    final p2Name = _playerName(_player2Id);

    if (gn == 6) {
      return {
        'date': _formatDateInput(_turnDate),
        'groupNumber': gn,
        'players': [
          {'playerId': _player1Id, 'name': p1Name, 'role': 'solo'},
          {
            'playerId': _player2Id,
            'name': p2Name,
            'role': 'helper',
            'fromGroupNumber': _playerGroupMap[_player2Id],
          },
        ],
        'notes': _notesController.text.trim(),
      };
    }

    return {
      'date': _formatDateInput(_turnDate),
      'groupNumber': gn,
      'players': [
        {'playerId': _player1Id, 'name': p1Name, 'role': 'regular'},
        {'playerId': _player2Id, 'name': p2Name, 'role': 'regular'},
      ],
      'notes': _notesController.text.trim(),
    };
  }

  Future<void> _saveTurn() async {
    if (_turnGroup == null || _player1Id == null || _player2Id == null) {
      _snack('Select group and both players');
      return;
    }

    setState(() => _loading = true);
    try {
      final body = _buildTurnBody();
      if (_editingTurnId != null) {
        await AdminMateTurnService.updateTurn(_editingTurnId!, body);
        _snack('Mate turn updated');
      } else {
        await AdminMateTurnService.createTurn(body);
        _snack('Mate turn saved');
      }
      _resetTurnForm();
      _turns = await AdminMateTurnService.fetchTurns();
      _suggested = await AdminMateTurnService.fetchSuggested();
      _applySuggestionToForm();
    } catch (e) {
      _snack('$e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _resetTurnForm() {
    _editingTurnId = null;
    _notesController.clear();
    _applySuggestionToForm();
  }

  void _editTurn(MateTurnModel turn) {
    _editingTurnId = turn.id;
    _turnDate = turn.date.toLocal();
    _turnGroup = turn.groupNumber;
    _notesController.text = turn.notes;

    if (turn.groupNumber == 6) {
      final solo = turn.players.where((p) => p.role == 'solo').firstOrNull;
      final helper = turn.players.where((p) => p.role == 'helper').firstOrNull;
      _player1Id = solo?.playerId;
      _player2Id = helper?.playerId;
    } else {
      _player1Id = turn.players.isNotEmpty ? turn.players[0].playerId : null;
      _player2Id = turn.players.length > 1 ? turn.players[1].playerId : null;
    }
    setState(() {});
    _tabs.animateTo(1);
  }

  Future<void> _deleteTurn(String id) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete mate turn?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Delete')),
        ],
      ),
    );
    if (ok != true) return;

    setState(() => _loading = true);
    try {
      await AdminMateTurnService.deleteTurn(id);
      _turns = await AdminMateTurnService.fetchTurns();
      _suggested = await AdminMateTurnService.fetchSuggested();
      _snack('Deleted');
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

  String _formatDateInput(DateTime d) {
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _turnDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _turnDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mate Turn Admin'),
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabs,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Groups'),
            Tab(text: 'Record'),
            Tab(text: 'History'),
          ],
        ),
      ),
      body: _loading && _players.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : _error != null && _players.isEmpty
              ? Center(child: Text(_error!))
              : Stack(
                  children: [
                    TabBarView(
                      controller: _tabs,
                      children: [
                        _buildGroupsTab(),
                        _buildRecordTab(),
                        _buildHistoryTab(),
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

  Widget _buildGroupsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Assign all 11 players to 6 groups (2+2+2+2+2+1).',
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 12),
        for (int n = 1; n <= 6; n++) ...[
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Group $n${n == 6 ? ' (solo)' : ''}',
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  for (int slot = 0; slot < (n == 6 ? 1 : 2); slot++)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: DropdownButtonFormField<String>(
                        initialValue: _groupSelections[n]?[slot],
                        decoration: InputDecoration(
                          labelText: 'Player ${slot + 1}',
                          isDense: true,
                        ),
                        items: _playersForDropdown().map((p) {
                          final id = p['_id']?.toString() ?? '';
                          return DropdownMenuItem(
                            value: id,
                            child: Text(p['name']?.toString() ?? ''),
                          );
                        }).toList(),
                        onChanged: (v) {
                          setState(() {
                            _groupSelections[n]![slot] = v;
                            _rebuildPlayerGroupMap();
                          });
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
        ElevatedButton(
            onPressed: _saveGroups, child: const Text('Save Groups')),
      ],
    );
  }

  Widget _buildRecordTab() {
    final gn = _turnGroup;
    final suggestion = _suggested;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (suggestion != null && _editingTurnId == null)
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: Text(
              'Suggested: Group ${suggestion.suggestedGroupNumber} — ${suggestion.playersLabel}',
            ),
          ),
        ListTile(
          title: const Text('Sunday date'),
          subtitle: Text(MateTurnModel.formatDate(_turnDate)),
          trailing: const Icon(Icons.calendar_today),
          onTap: _pickDate,
        ),
        DropdownButtonFormField<int>(
          initialValue: gn,
          decoration: const InputDecoration(labelText: 'Group'),
          items: List.generate(6, (i) {
            final n = i + 1;
            return DropdownMenuItem(value: n, child: Text('Group $n'));
          }),
          onChanged: (v) {
            setState(() => _turnGroup = v);
            _onGroupChanged(resetPlayers: true);
          },
        ),
        const SizedBox(height: 12),
        if (gn != null && gn == 6) ...[
          DropdownButtonFormField<String>(
            initialValue: _player1Id,
            decoration: const InputDecoration(labelText: 'Solo player'),
            items: _playersInGroup(6).map((p) {
              final id = p['_id']?.toString() ?? '';
              return DropdownMenuItem(
                value: id,
                child: Text(p['name']?.toString() ?? ''),
              );
            }).toList(),
            onChanged: (v) => setState(() => _player1Id = v),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            initialValue: _player2Id,
            decoration: const InputDecoration(labelText: 'Helper (Groups 1–5)'),
            items: _helperCandidates().map((p) {
              final id = p['_id']?.toString() ?? '';
              final g = _playerGroupMap[id];
              return DropdownMenuItem(
                value: id,
                child: Text('${p['name']} (Group $g)'),
              );
            }).toList(),
            onChanged: (v) => setState(() => _player2Id = v),
          ),
        ] else if (gn != null) ...[
          DropdownButtonFormField<String>(
            initialValue: _player1Id,
            decoration: const InputDecoration(labelText: 'Player 1'),
            items: _playersInGroup(gn).map((p) {
              final id = p['_id']?.toString() ?? '';
              return DropdownMenuItem(
                value: id,
                child: Text(p['name']?.toString() ?? ''),
              );
            }).toList(),
            onChanged: (v) => setState(() => _player1Id = v),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            initialValue: _player2Id,
            decoration: const InputDecoration(labelText: 'Player 2'),
            items: _playersInGroup(gn).map((p) {
              final id = p['_id']?.toString() ?? '';
              return DropdownMenuItem(
                value: id,
                child: Text(p['name']?.toString() ?? ''),
              );
            }).toList(),
            onChanged: (v) => setState(() => _player2Id = v),
          ),
        ],
        const SizedBox(height: 12),
        TextField(
          controller: _notesController,
          decoration: const InputDecoration(
            labelText: 'Notes (optional)',
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: _saveTurn,
          child: Text(
              _editingTurnId != null ? 'Update Mate Turn' : 'Save Mate Turn'),
        ),
        if (_editingTurnId != null)
          TextButton(
              onPressed: _resetTurnForm, child: const Text('Cancel edit')),
      ],
    );
  }

  Widget _buildHistoryTab() {
    if (_turns.isEmpty) {
      return const Center(child: Text('No mate turns recorded yet'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _turns.length,
      itemBuilder: (context, index) {
        final turn = _turns[index];
        return Card(
          child: ListTile(
            title: Text(turn.formattedDate()),
            subtitle: Text(
                '${turn.playersLabel}${turn.notes.isNotEmpty ? '\n${turn.notes}' : ''}'),
            isThreeLine: turn.notes.isNotEmpty,
            trailing: PopupMenuButton<String>(
              onSelected: (v) {
                if (v == 'edit') _editTurn(turn);
                if (v == 'delete') _deleteTurn(turn.id);
              },
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'edit', child: Text('Edit')),
                PopupMenuItem(value: 'delete', child: Text('Delete')),
              ],
            ),
          ),
        );
      },
    );
  }
}

extension _FirstOrNullMate<E> on Iterable<E> {
  E? get firstOrNull {
    final it = iterator;
    if (!it.moveNext()) return null;
    return it.current;
  }
}
