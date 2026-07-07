import 'package:flutter/material.dart';
import 'package:teamawesomesozeith/services/admin/admin_team_rules_service.dart';
import 'package:teamawesomesozeith/services/team_rules_service.dart';

class AdminTeamRulesPage extends StatefulWidget {
  const AdminTeamRulesPage({super.key});

  @override
  State<AdminTeamRulesPage> createState() => _AdminTeamRulesPageState();
}

class _AdminTeamRulesPageState extends State<AdminTeamRulesPage> {
  bool _loading = true;
  bool _saving = false;
  String? _error;
  List<String> _rules = [];
  final _newRuleController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _newRuleController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await AdminTeamRulesService.fetchRules();
      setState(() => _rules = List<String>.from(data.rules));
    } catch (e) {
      setState(() => _error = TeamRulesService.displayError(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _addRule() {
    final text = _newRuleController.text.trim();
    if (text.isEmpty) {
      _snack('Enter a rule');
      return;
    }
    setState(() {
      _rules.add(text);
      _newRuleController.clear();
    });
  }

  void _editRule(int index) async {
    final controller = TextEditingController(text: _rules[index]);
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit rule'),
        content: TextField(
          controller: controller,
          maxLines: 4,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (result == null || result.isEmpty) return;
    setState(() => _rules[index] = result);
  }

  void _deleteRule(int index) {
    setState(() => _rules.removeAt(index));
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await AdminTeamRulesService.saveRules(_rules);
      _snack('Rules published');
    } catch (e) {
      _snack(TeamRulesService.displayError(e));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Team Rules'),
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: _saving || _loading ? null : _save,
            child: _saving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text(
                    'Publish',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Add rules players must follow. Tap Publish when done.',
                            style: theme.textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _newRuleController,
                            maxLines: 3,
                            decoration: InputDecoration(
                              labelText: 'New rule',
                              border: const OutlineInputBorder(),
                              suffixIcon: IconButton(
                                icon: const Icon(Icons.add_circle),
                                onPressed: _addRule,
                              ),
                            ),
                            onSubmitted: (_) => _addRule(),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton.icon(
                            onPressed: _addRule,
                            icon: const Icon(Icons.add),
                            label: const Text('Add to list'),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    Expanded(
                      child: _rules.isEmpty
                          ? const Center(child: Text('No rules yet. Add some above.'))
                          : ReorderableListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: _rules.length,
                              onReorder: (oldIndex, newIndex) {
                                setState(() {
                                  if (newIndex > oldIndex) newIndex -= 1;
                                  final item = _rules.removeAt(oldIndex);
                                  _rules.insert(newIndex, item);
                                });
                              },
                              itemBuilder: (context, index) {
                                return Card(
                                  key: ValueKey('rule_$index${_rules[index]}'),
                                  margin: const EdgeInsets.only(bottom: 8),
                                  child: ListTile(
                                    leading: ReorderableDragStartListener(
                                      index: index,
                                      child: Icon(Icons.drag_handle, color: Colors.grey[600]),
                                    ),
                                    title: Text('${index + 1}. ${_rules[index]}'),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.edit_outlined),
                                          onPressed: () => _editRule(index),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                                          onPressed: () => _deleteRule(index),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
    );
  }
}
