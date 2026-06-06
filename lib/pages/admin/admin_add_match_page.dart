import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:teamawesomesozeith/services/admin/admin_next_match_service.dart';

class AdminAddMatchPage extends StatefulWidget {
  const AdminAddMatchPage({super.key});

  @override
  State<AdminAddMatchPage> createState() => _AdminAddMatchPageState();
}

class _AdminAddMatchPageState extends State<AdminAddMatchPage> {
  bool _loading = true;
  bool _busy = false;
  String? _error;
  List<AdminNextMatchModel> _matches = [];
  String? _editingId;

  final _opponent = TextEditingController();
  final _seriesName = TextEditingController();
  final _totalMatches = TextEditingController();
  final _matchNumber = TextEditingController();
  final _seriesLeader = TextEditingController();
  final _seriesScoreOur = TextEditingController();
  final _seriesScoreOpp = TextEditingController();
  final _venue = TextEditingController();
  final _overs = TextEditingController();

  bool _isSeries = false;
  bool _isHomeMatch = false;
  String _status = 'upcoming';
  DateTime _date = DateTime.now().add(const Duration(days: 7));

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _opponent.dispose();
    _seriesName.dispose();
    _totalMatches.dispose();
    _matchNumber.dispose();
    _seriesLeader.dispose();
    _seriesScoreOur.dispose();
    _seriesScoreOpp.dispose();
    _venue.dispose();
    _overs.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      _matches = await AdminNextMatchService.fetchMatches();
    } catch (e) {
      _error = e.toString();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _resetForm() {
    _editingId = null;
    _opponent.clear();
    _seriesName.clear();
    _totalMatches.clear();
    _matchNumber.clear();
    _seriesLeader.clear();
    _seriesScoreOur.clear();
    _seriesScoreOpp.clear();
    _venue.clear();
    _overs.clear();
    _isSeries = false;
    _isHomeMatch = false;
    _status = 'upcoming';
    _date = DateTime.now().add(const Duration(days: 7));
  }

  AdminNextMatchModel _buildModel() {
    return AdminNextMatchModel(
      id: _editingId ?? '',
      opponent: _opponent.text.trim(),
      isSeries: _isSeries,
      date: _date,
      seriesName: _seriesName.text.trim(),
      totalMatches: int.tryParse(_totalMatches.text.trim()),
      matchNumber: int.tryParse(_matchNumber.text.trim()),
      seriesLeader: _seriesLeader.text.trim(),
      seriesScoreOur: int.tryParse(_seriesScoreOur.text.trim()) ?? 0,
      seriesScoreOpponent: int.tryParse(_seriesScoreOpp.text.trim()) ?? 0,
      venue: _venue.text.trim(),
      overs: int.tryParse(_overs.text.trim()),
      isHomeMatch: _isHomeMatch,
      status: _status,
    );
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_date),
    );
    if (time == null) return;

    setState(() {
      _date = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  Future<void> _save() async {
    if (_opponent.text.trim().isEmpty) {
      _snack('Opponent is required');
      return;
    }

    setState(() => _busy = true);
    try {
      final model = _buildModel();
      if (_editingId != null) {
        await AdminNextMatchService.updateMatch(_editingId!, model);
        _snack('Match updated');
      } else {
        await AdminNextMatchService.createMatch(model);
        _snack('Match added');
      }
      _resetForm();
      await _load();
    } catch (e) {
      _snack('$e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _edit(AdminNextMatchModel m) async {
    setState(() {
      _editingId = m.id;
      _opponent.text = m.opponent;
      _isSeries = m.isSeries;
      _date = m.date.toLocal();
      _seriesName.text = m.seriesName ?? '';
      _totalMatches.text = m.totalMatches?.toString() ?? '';
      _matchNumber.text = m.matchNumber?.toString() ?? '';
      _seriesLeader.text = m.seriesLeader ?? '';
      _seriesScoreOur.text = m.seriesScoreOur.toString();
      _seriesScoreOpp.text = m.seriesScoreOpponent.toString();
      _venue.text = m.venue ?? '';
      _overs.text = m.overs?.toString() ?? '';
      _isHomeMatch = m.isHomeMatch;
      _status = m.status;
    });
  }

  Future<void> _delete(AdminNextMatchModel m) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete match?'),
        content: Text('Remove match vs ${m.opponent}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    setState(() => _busy = true);
    try {
      await AdminNextMatchService.deleteMatch(m.id);
      if (_editingId == m.id) _resetForm();
      _snack('Match deleted');
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
    final dateFmt = DateFormat('EEE, d MMM yyyy • HH:mm');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Next Match'),
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
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  _editingId == null ? 'Add match' : 'Edit match',
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                                const SizedBox(height: 12),
                                TextField(
                                  controller: _opponent,
                                  decoration: const InputDecoration(
                                    labelText: 'Opponent *',
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                DropdownButtonFormField<bool>(
                                  value: _isSeries,
                                  decoration: const InputDecoration(
                                    labelText: 'Match type',
                                    border: OutlineInputBorder(),
                                  ),
                                  items: const [
                                    DropdownMenuItem(value: false, child: Text('Individual')),
                                    DropdownMenuItem(value: true, child: Text('Series')),
                                  ],
                                  onChanged: (v) => setState(() => _isSeries = v ?? false),
                                ),
                                const SizedBox(height: 12),
                                OutlinedButton.icon(
                                  onPressed: _pickDateTime,
                                  icon: const Icon(Icons.event),
                                  label: Text(dateFmt.format(_date)),
                                ),
                                if (_isSeries) ...[
                                  const SizedBox(height: 12),
                                  TextField(
                                    controller: _seriesName,
                                    decoration: const InputDecoration(
                                      labelText: 'Series name',
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  TextField(
                                    controller: _matchNumber,
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(
                                      labelText: 'Match number in series',
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  TextField(
                                    controller: _totalMatches,
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(
                                      labelText: 'Total matches in series',
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  TextField(
                                    controller: _seriesLeader,
                                    decoration: const InputDecoration(
                                      labelText: 'Series leader',
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: TextField(
                                          controller: _seriesScoreOur,
                                          keyboardType: TextInputType.number,
                                          decoration: const InputDecoration(
                                            labelText: 'Our series wins',
                                            border: OutlineInputBorder(),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: TextField(
                                          controller: _seriesScoreOpp,
                                          keyboardType: TextInputType.number,
                                          decoration: const InputDecoration(
                                            labelText: 'Their series wins',
                                            border: OutlineInputBorder(),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                                const SizedBox(height: 12),
                                TextField(
                                  controller: _venue,
                                  decoration: const InputDecoration(
                                    labelText: 'Venue',
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                TextField(
                                  controller: _overs,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    labelText: 'Overs (optional)',
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                SwitchListTile(
                                  contentPadding: EdgeInsets.zero,
                                  title: const Text('Home match'),
                                  value: _isHomeMatch,
                                  onChanged: (v) => setState(() => _isHomeMatch = v),
                                ),
                                DropdownButtonFormField<String>(
                                  value: _status,
                                  decoration: const InputDecoration(
                                    labelText: 'Status',
                                    border: OutlineInputBorder(),
                                  ),
                                  items: const [
                                    DropdownMenuItem(value: 'upcoming', child: Text('Upcoming')),
                                    DropdownMenuItem(value: 'completed', child: Text('Completed')),
                                  ],
                                  onChanged: (v) => setState(() => _status = v ?? 'upcoming'),
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: _busy ? null : _save,
                                        icon: const Icon(Icons.save),
                                        label: Text(_editingId == null ? 'Save' : 'Update'),
                                      ),
                                    ),
                                    if (_editingId != null) ...[
                                      const SizedBox(width: 8),
                                      OutlinedButton(
                                        onPressed: () => setState(_resetForm),
                                        child: const Text('Cancel'),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text('Matches', style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 8),
                        if (_matches.isEmpty)
                          const Text('No matches yet.')
                        else
                          ..._matches.map((m) => Card(
                                child: ListTile(
                                  title: Text('vs ${m.opponent}'),
                                  subtitle: Text(
                                    '${m.isSeries ? "Series" : "Individual"} • ${dateFmt.format(m.date.toLocal())}${m.venue != null ? "\n${m.venue}" : ""}',
                                  ),
                                  isThreeLine: true,
                                  trailing: PopupMenuButton<String>(
                                    onSelected: (action) {
                                      if (action == 'edit') _edit(m);
                                      if (action == 'delete') _delete(m);
                                    },
                                    itemBuilder: (_) => const [
                                      PopupMenuItem(value: 'edit', child: Text('Edit')),
                                      PopupMenuItem(value: 'delete', child: Text('Delete')),
                                    ],
                                  ),
                                ),
                              )),
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
