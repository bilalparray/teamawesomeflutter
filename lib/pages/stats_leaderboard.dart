import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:teamawesomesozeith/environment/environemnt.dart';
import 'package:teamawesomesozeith/models/player_stat.dart';

/// StatsLeaderboardPage
/// - Calls POST /api/stats/top
/// - Expects response: { metric, scope, players: [ { _id, name, role, image (url), count } ] }
/// - Responsive UI: controls adapt to screen width (row on wide, column on narrow)
/// - Images are treated as URLs (not base64)

class StatsLeaderboardPage extends StatefulWidget {
  const StatsLeaderboardPage({Key? key}) : super(key: key);

  @override
  State<StatsLeaderboardPage> createState() => _StatsLeaderboardPageState();
}

class _StatsLeaderboardPageState extends State<StatsLeaderboardPage> {
  // Change this to your server address (include port if needed)
  String serverUrl = Environment.baseUrl;

  final List<String> metrics = ['50s', '100s', 'wickets'];
  final List<String> scopes = ['career', 'year'];

  String selectedMetric = '50s';
  String selectedScope = 'career';

  bool loading = false;
  String? error;
  List<PlayerStat> players = [];

  Future<void> fetchLeaderboard() async {
    setState(() {
      loading = true;
      error = null;
    });

    final url = Uri.parse('$serverUrl/api/stats/top');
    final body = {
      'metric': selectedMetric,
      'scope': selectedScope,
    };

    try {
      final resp = await http.post(url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(body));

      if (resp.statusCode != 200) {
        setState(() {
          error = 'Server returned ${resp.statusCode}: ${resp.body}';
          loading = false;
        });
        return;
      }

      final Map<String, dynamic> jsonResp = jsonDecode(resp.body);
      final List<dynamic> list = jsonResp['players'] ?? [];

      final fetched = list.map((e) => PlayerStat.fromJson(e)).toList();

      setState(() {
        players = fetched;
        loading = false;
      });
    } catch (e) {
      setState(() {
        error = 'Request failed: $e';
        loading = false;
      });
    }
  }

  /// Responsive controls:
  /// - On narrow screens: stacked column
  /// - On wide screens: single row
  Widget _buildControls(double maxWidth) {
    // threshold can be tuned (e.g. 520, 600)
    const narrowThreshold = 520.0;
    final isNarrow = maxWidth < narrowThreshold;

    final metricField = DropdownButtonFormField<String>(
      value: selectedMetric,
      decoration: InputDecoration(
        labelText: 'Metric',
        filled: true,
        fillColor: Theme.of(context).colorScheme.surfaceVariant,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      ),
      items: metrics
          .map((m) => DropdownMenuItem(value: m, child: Text(m)))
          .toList(),
      onChanged: (v) {
        if (v == null) return;
        setState(() => selectedMetric = v);
      },
    );

    final scopeField = DropdownButtonFormField<String>(
      value: selectedScope,
      decoration: InputDecoration(
        labelText: 'Scope',
        filled: true,
        fillColor: Theme.of(context).colorScheme.surfaceVariant,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      ),
      items: scopes
          .map((s) => DropdownMenuItem(value: s, child: Text(s)))
          .toList(),
      onChanged: (v) {
        if (v == null) return;
        setState(() => selectedScope = v);
      },
    );

    final fetchButton = ElevatedButton.icon(
      onPressed: loading ? null : fetchLeaderboard,
      icon: const Icon(Icons.search),
      label: const Text('Fetch'),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );

    if (isNarrow) {
      // stacked layout for mobile / narrow widths
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            metricField,
            const SizedBox(height: 10),
            scopeField,
            const SizedBox(height: 12),
            SizedBox(height: 48, child: fetchButton),
          ],
        ),
      );
    } else {
      // horizontal layout for tablet/desktop
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Expanded(child: metricField),
            const SizedBox(width: 12),
            SizedBox(width: 180, child: scopeField),
            const SizedBox(width: 12),
            SizedBox(height: 48, child: fetchButton),
          ],
        ),
      );
    }
  }

  Future<void> _onRefresh() async {
    await fetchLeaderboard();
  }

  Widget _buildList() {
    if (loading) return const Center(child: CircularProgressIndicator());
    if (error != null)
      return Center(
          child: Text(error!, style: const TextStyle(color: Colors.red)));
    if (players.isEmpty) return const Center(child: Text('No players found'));

    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        itemCount: players.length,
        itemBuilder: (context, index) {
          final p = players[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            elevation: 3,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              leading: _buildAvatar(p),
              title: Text(p.name ?? 'Unknown',
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 16)),
              subtitle:
                  Text(p.role ?? '', style: const TextStyle(fontSize: 14)),
              trailing: Chip(
                label: Text('${p.count}',
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
                backgroundColor: Theme.of(context).colorScheme.primary,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAvatar(PlayerStat p) {
    if (p.imageUrl != null && p.imageUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: 28,
        backgroundColor: Colors.grey.shade200,
        backgroundImage: NetworkImage(p.imageUrl!),
      );
    }

    // Placeholder with initials
    final initials =
        (p.name ?? '?').trim().isNotEmpty ? _initialsFromName(p.name!) : '?';
    return CircleAvatar(
      radius: 28,
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      child: Text(initials,
          style: TextStyle(
              color: Theme.of(context).colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.bold)),
    );
  }

  String _initialsFromName(String name) {
    final parts = name.split(' ').where((s) => s.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return '${parts.first.substring(0, 1)}${parts.last.substring(0, 1)}'
        .toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stats Leaderboard'),
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Column(
              children: [
                const SizedBox(height: 8),
                _buildControls(constraints.maxWidth),
                const SizedBox(height: 8),
                Expanded(child: _buildList()),
              ],
            );
          },
        ),
      ),
    );
  }
}
