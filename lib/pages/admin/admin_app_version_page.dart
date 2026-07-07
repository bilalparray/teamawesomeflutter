import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:teamawesomesozeith/services/admin/admin_app_info_service.dart';

class AdminAppVersionPage extends StatefulWidget {
  const AdminAppVersionPage({super.key});

  @override
  State<AdminAppVersionPage> createState() => _AdminAppVersionPageState();
}

class _AdminAppVersionPageState extends State<AdminAppVersionPage> {
  final _minimumVersionController = TextEditingController();
  bool _maintenanceMode = false;
  bool _loading = true;
  bool _saving = false;
  String? _error;
  String _installedVersion = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _minimumVersionController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final info = await AdminAppInfoService.fetch();
      setState(() {
        _installedVersion = packageInfo.version;
        _minimumVersionController.text = info.minimumVersion;
        _maintenanceMode = info.isError;
      });
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _save() async {
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await AdminAppInfoService.save(
        minimumVersion: _minimumVersionController.text,
        isError: _maintenanceMode,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('App version settings saved')),
        );
      }
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Force Update'),
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'How it works',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Set minimum version to force players below that version '
                          'to update from Play Store before using the app. '
                          'Installed app version: $_installedVersion',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[700],
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _minimumVersionController,
                  decoration: const InputDecoration(
                    labelText: 'Minimum required version',
                    hintText: 'e.g. 1.0.10',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.text,
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Maintenance mode'),
                  subtitle: const Text(
                    'Blocks all users with a maintenance screen',
                  ),
                  value: _maintenanceMode,
                  onChanged: _saving
                      ? null
                      : (value) => setState(() => _maintenanceMode = value),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    _error!,
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                ],
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: _saving ? null : _save,
                  icon: _saving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save),
                  label: Text(_saving ? 'Saving…' : 'Save settings'),
                ),
              ],
            ),
    );
  }
}
