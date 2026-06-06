import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:teamawesomesozeith/models/editable_scorecard_row.dart';
import 'package:teamawesomesozeith/services/admin/admin_scorecard_service.dart';

class AdminScorecardPage extends StatefulWidget {
  const AdminScorecardPage({super.key});

  @override
  State<AdminScorecardPage> createState() => _AdminScorecardPageState();
}

class _AdminScorecardPageState extends State<AdminScorecardPage> {
  String? _pdfFileName;
  Uint8List? _pdfBytes;
  List<String> _extractedPlayers = [];
  final Set<String> _latePlayers = {};
  List<EditableScorecardRow> _editableRows = [];
  String _search = '';
  bool _busy = false;
  bool _picking = false;
  String? _status;

  @override
  void dispose() {
    _disposeEditableRows();
    super.dispose();
  }

  void _disposeEditableRows() {
    for (final row in _editableRows) {
      row.dispose();
    }
    _editableRows = [];
  }

  void _setEditableRows(List<Map<String, dynamic>> output) {
    _disposeEditableRows();
    _editableRows =
        output.map((e) => EditableScorecardRow.fromMap(e)).toList();
  }

  Future<void> _pickPdf() async {
    if (_picking || _busy) return;

    setState(() {
      _picking = true;
      _status = 'Opening file picker…';
    });

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: false,
        withData: !kIsWeb,
        lockParentWindow: false,
      );

      if (!mounted) return;

      if (result == null || result.files.isEmpty) {
        setState(() => _status = 'No file selected');
        return;
      }

      final file = result.files.first;
      final bytes = await _readPdfBytes(file);
      if (bytes == null || bytes.isEmpty) {
        _showSnack('Could not read PDF file');
        setState(() => _status = 'Could not read PDF');
        return;
      }

      if (!file.name.toLowerCase().endsWith('.pdf')) {
        _showSnack('Please choose a PDF file');
        setState(() => _status = 'Invalid file type');
        return;
      }

      setState(() {
        _pdfFileName = file.name;
        _pdfBytes = bytes;
        _extractedPlayers = [];
        _latePlayers.clear();
        _setEditableRows([]);
        _status = 'PDF selected: ${file.name}';
      });
    } catch (e) {
      if (!mounted) return;
      _showSnack('Could not open file picker: $e');
      setState(() => _status = 'File picker failed');
    } finally {
      if (mounted) setState(() => _picking = false);
    }
  }

  Future<Uint8List?> _readPdfBytes(PlatformFile file) async {
    if (file.bytes != null && file.bytes!.isNotEmpty) {
      return Uint8List.fromList(file.bytes!);
    }

    final path = file.path;
    if (path != null && path.isNotEmpty && !kIsWeb) {
      try {
        return await File(path).readAsBytes();
      } catch (e) {
        debugPrint('Failed to read PDF from path: $e');
      }
    }

    return null;
  }

  Future<void> _extractPlayers() async {
    final bytes = _pdfBytes;
    final name = _pdfFileName;
    if (bytes == null || name == null) {
      _showSnack('Select a PDF first');
      return;
    }

    setState(() {
      _busy = true;
      _status = 'Extracting players…';
    });

    try {
      final names = await AdminScorecardService.extractPlayers(
        pdfBytes: bytes,
        filename: name,
      );
      setState(() {
        _extractedPlayers = names;
        _latePlayers.clear();
        _setEditableRows([]);
        _status = 'Found ${names.length} players';
      });
    } catch (e) {
      _showSnack('$e');
      setState(() => _status = 'Extract failed');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _processScorecard() async {
    final bytes = _pdfBytes;
    final name = _pdfFileName;
    if (bytes == null || name == null) {
      _showSnack('Select a PDF first');
      return;
    }

    setState(() {
      _busy = true;
      _status = 'Processing scorecard…';
    });

    try {
      final output = await AdminScorecardService.processScorecard(
        pdfBytes: bytes,
        filename: name,
        latePlayers: _latePlayers.toList(),
      );
      setState(() {
        _setEditableRows(output);
        final withStats = output.where((p) {
          final runs = p['runsScored'] as num? ?? 0;
          final balls = p['balls'] as num? ?? 0;
          return runs > 0 || balls > 0;
        }).length;
        if (withStats == 0 && output.isNotEmpty) {
          _status =
              'Processed ${output.length} players — no stats read from PDF; edit manually or redeploy backend (parser v7+)';
        } else {
          _status = 'Processed ${output.length} players ($withStats with stats)';
        }
      });
    } catch (e) {
      _showSnack('$e');
      setState(() => _status = 'Process failed');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _applyToDb() async {
    if (_editableRows.isEmpty) {
      _showSnack('Process scorecard first');
      return;
    }

    final payload =
        _editableRows.map((row) => row.toApiPayload()).toList();

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Apply to database?'),
        content: Text(
          'This will append scores for ${payload.length} players to the database.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Apply'),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    setState(() {
      _busy = true;
      _status = 'Applying to database…';
    });

    try {
      final result = await AdminScorecardService.applyToDb(payload);
      _showSnack(
        '${result.message} Updated: ${result.updatedCount}, Skipped: ${result.skippedCount}',
      );
      setState(() => _status = 'Applied to DB');
    } catch (e) {
      _showSnack('$e');
      setState(() => _status = 'Apply failed');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  List<String> get _filteredPlayers {
    final q = _search.toLowerCase().trim();
    if (q.isEmpty) return _extractedPlayers;
    return _extractedPlayers.where((n) => n.toLowerCase().contains(q)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pickerDisabled = _busy || _picking;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scorecard Processor'),
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text('1. Select PDF', style: theme.textTheme.titleSmall),
                      const SizedBox(height: 8),
                      OutlinedButton.icon(
                        onPressed: pickerDisabled ? null : _pickPdf,
                        icon: _picking
                            ? SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: theme.colorScheme.primary,
                                ),
                              )
                            : const Icon(Icons.upload_file),
                        label: Text(_pdfFileName ?? 'Choose scorecard PDF'),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: _busy || _pdfBytes == null ? null : _extractPlayers,
                        icon: const Icon(Icons.person_search),
                        label: const Text('Extract Players'),
                      ),
                    ],
                  ),
                ),
              ),
              if (_extractedPlayers.isNotEmpty) ...[
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text('2. Late players (optional)',
                            style: theme.textTheme.titleSmall),
                        const SizedBox(height: 8),
                        TextField(
                          decoration: const InputDecoration(
                            labelText: 'Search players',
                            prefixIcon: Icon(Icons.search),
                          ),
                          onChanged: (v) => setState(() => _search = v),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            TextButton(
                              onPressed: () => setState(() {
                                _latePlayers.addAll(_extractedPlayers);
                              }),
                              child: const Text('Select all'),
                            ),
                            TextButton(
                              onPressed: () =>
                                  setState(() => _latePlayers.clear()),
                              child: const Text('Clear'),
                            ),
                          ],
                        ),
                        ..._filteredPlayers.map((name) {
                          return CheckboxListTile(
                            dense: true,
                            title: Text(name),
                            value: _latePlayers.contains(name),
                            onChanged: (v) {
                              setState(() {
                                if (v == true) {
                                  _latePlayers.add(name);
                                } else {
                                  _latePlayers.remove(name);
                                }
                              });
                            },
                          );
                        }),
                        const SizedBox(height: 8),
                        ElevatedButton.icon(
                          onPressed: _busy ? null : _processScorecard,
                          icon: const Icon(Icons.play_arrow),
                          label: const Text('Process Scorecard'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              if (_editableRows.isNotEmpty) ...[
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text('3. Review & apply',
                            style: theme.textTheme.titleSmall),
                        const SizedBox(height: 4),
                        Text(
                          'Edit stats before saving. Adjusted runs = runs + not out (+10) − late (−10).',
                          style: theme.textTheme.bodySmall,
                        ),
                        const SizedBox(height: 12),
                        ..._editableRows.map((row) => _PlayerEditRow(
                              row: row,
                              onChanged: () => setState(() {}),
                            )),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: _busy ? null : _applyToDb,
                          icon: const Icon(Icons.save),
                          label: const Text('Apply to Database'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              if (_status != null) ...[
                const SizedBox(height: 12),
                Text(_status!, style: theme.textTheme.bodySmall),
              ],
            ],
          ),
          if (_busy)
            IgnorePointer(
              child: Container(
                color: Colors.black26,
                child: const Center(child: CircularProgressIndicator()),
              ),
            ),
        ],
      ),
    );
  }
}

class _PlayerEditRow extends StatelessWidget {
  const _PlayerEditRow({
    required this.row,
    required this.onChanged,
  });

  final EditableScorecardRow row;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            row.playerName,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: row.runsController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Runs',
                    isDense: true,
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (_) => onChanged(),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: row.ballsController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Balls',
                    isDense: true,
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (_) => onChanged(),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: row.wicketsController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Wkts',
                    isDense: true,
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (_) => onChanged(),
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: CheckboxListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Not out'),
                  value: row.isNotOut,
                  onChanged: (v) {
                    row.isNotOut = v == true;
                    onChanged();
                  },
                ),
              ),
              Expanded(
                child: CheckboxListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Late'),
                  value: row.isLate,
                  onChanged: (v) {
                    row.isLate = v == true;
                    onChanged();
                  },
                ),
              ),
            ],
          ),
          Text(
            'Adjusted runs: ${row.adjustedRuns}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Divider(height: 24),
        ],
      ),
    );
  }
}
