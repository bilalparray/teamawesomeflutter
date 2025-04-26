import 'package:flutter/material.dart';
import 'dart:convert';

class PlayerProfilePage extends StatelessWidget {
  final Map<String, dynamic> player;
  const PlayerProfilePage({super.key, required this.player});

  @override
  Widget build(BuildContext context) {
    final scores = player['scores'] ?? {};
    final careerStats = scores['career'] ?? {};

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(player['name'] ?? 'Player Profile'),
          bottom: TabBar(
            indicatorColor: Colors.green,
            labelColor: Colors.green[800],
            unselectedLabelColor: Colors.grey,
            tabs: const [
              Tab(text: 'Recent'),
              Tab(text: 'Current Year'),
              Tab(text: 'Career'),
            ],
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.only(bottom: 80),
          child: Column(
            children: [
              const SizedBox(height: 16),
              CircleAvatar(
                backgroundImage: _getImageProvider(player),
                radius: 50,
              ),
              const SizedBox(height: 12),
              Text(
                player['role'] ?? 'Player',
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: TabBarView(
                  children: [
                    _statsTable(_getRecentStats(scores)),
                    _statsTable(_getCurrentYearStats(scores)),
                    _statsTable(_getCareerStats(careerStats)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  ImageProvider _getImageProvider(Map<String, dynamic> player) {
    if (player['image'] != null && player['image'].toString().isNotEmpty) {
      try {
        final imageString = player['image'].toString();
        final base64String = imageString.contains(',')
            ? imageString.split(',').last
            : imageString;
        return MemoryImage(base64Decode(base64String));
      } catch (e) {
        return const AssetImage('assets/players/profile.png');
      }
    }
    return const AssetImage('assets/players/profile.png');
  }

  Map<String, String> _getRecentStats(Map<String, dynamic> scores) {
    return {
      'Last Match Runs': scores['runs']?.last?.toString() ?? 'N/A',
      'Last Match Wickets': scores['wickets']?.last?.toString() ?? 'N/A',
      'Balls Faced': scores['balls']?.last?.toString() ?? 'N/A',
      'Last 4 Matches Avg': _calculateAverage(scores['lastfour']),
    };
  }

  Map<String, String> _getCurrentYearStats(Map<String, dynamic> scores) {
    return {
      'Total Runs': _sumValues(scores['runs']),
      'Total Wickets': _sumValues(scores['wickets']),
      'Matches Played': _countMatches(scores['innings']),
      'Balls Faced': _sumValues(scores['balls']),
    };
  }

  Map<String, String> _getCareerStats(Map<String, dynamic> careerStats) {
    return {
      'Total Runs': _sumValues(careerStats['runs']),
      'Total Wickets': _sumValues(careerStats['wickets']),
      'Matches Played': _countMatches(careerStats['innings']),
      'Balls Bowled': _sumValues(careerStats['balls']),
      'Current Ranking': careerStats['ranking']?.toString() ?? 'N/A',
    };
  }

  String _calculateAverage(List<dynamic>? values) {
    if (values == null || values.isEmpty) return 'N/A';
    try {
      final nums = values
          .where((v) => v != null && v.toString().isNotEmpty)
          .map((v) => double.parse(v.toString()))
          .toList();
      if (nums.isEmpty) return 'N/A';
      return (nums.reduce((a, b) => a + b) / nums.length).toStringAsFixed(1);
    } catch (e) {
      return 'N/A';
    }
  }

  String _sumValues(List<dynamic>? values) {
    if (values == null || values.isEmpty) return 'N/A';
    try {
      return values
          .where((v) => v != null && v.toString().isNotEmpty)
          .map((v) => int.parse(v.toString()))
          .fold(0, (a, b) => a + b)
          .toString();
    } catch (e) {
      return 'N/A';
    }
  }

  String _countMatches(List<dynamic>? innings) {
    if (innings == null) return 'N/A';
    return innings
        .where((i) => i != null && i.toString().isNotEmpty)
        .length
        .toString();
  }

  Widget _statsTable(Map<String, String> stats) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      children: stats.entries.map((e) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(e.key, style: const TextStyle(fontWeight: FontWeight.w500)),
              Text(e.value,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        );
      }).toList(),
    );
  }
}
