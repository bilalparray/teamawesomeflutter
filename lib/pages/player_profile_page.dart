import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:intl/intl.dart';

class PlayerProfilePage extends StatefulWidget {
  final Map<String, dynamic> player;

  const PlayerProfilePage({super.key, required this.player});

  @override
  _PlayerProfilePageState createState() => _PlayerProfilePageState();
}

class _PlayerProfilePageState extends State<PlayerProfilePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scores = widget.player['scores'] ?? {};
    final careerStats = scores['career'] ?? {};
    final theme = Theme.of(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Collapsible App Bar with White Text and Back Button
          SliverAppBar(
            expandedHeight: 400,
            pinned: true,
            backgroundColor: theme.primaryColor,
            title: Text(
              widget.player['name'] ?? 'Player Profile',
              style: const TextStyle(color: Colors.white),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: _buildFlexibleSpaceBackground(),
              titlePadding: EdgeInsets.zero,
            ),
          ),
          // Sticky Tabs
          SliverPersistentHeader(
            pinned: true,
            delegate: _StickyTabDelegate(
              tabs: ['Recent Form', 'Year Stats', 'Career'],
              theme: theme,
              controller: _tabController,
            ),
          ),
          // Tab Content
          SliverFillRemaining(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildStatsSection(_processRecentStats(scores)),
                _buildStatsSection(_processYearStats(scores)),
                _buildStatsSection(_processCareerStats(careerStats)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ### Flexible Space Background
  Widget _buildFlexibleSpaceBackground() {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image(
          image: _getImageProvider(widget.player),
          fit: BoxFit.cover,
        ),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.black.withOpacity(0.8),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildInfoPill('Born', _parseDate(widget.player['born'])),
                  _buildInfoPill('Debut', _parseDate(widget.player['debut'])),
                  _buildInfoPill(
                      'Batting', widget.player['battingstyle'] ?? 'N/A'),
                  _buildInfoPill(
                      'Bowling', widget.player['bowlingstyle'] ?? 'N/A'),
                  _buildInfoPill('Role', widget.player['role'] ?? 'N/A'),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ### Info Pill Widget
  Widget _buildInfoPill(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '$label: $value',
        style: const TextStyle(color: Colors.white, fontSize: 14),
      ),
    );
  }

  // ### Stats Section
  Widget _buildStatsSection(Map<String, String> stats) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: stats.entries
            .map((entry) => _buildStatCard(entry.key, entry.value))
            .toList(),
      ),
    );
  }

  // ### Stat Card Widget
  Widget _buildStatCard(String title, String value) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // ### Data Processing Functions
  Map<String, String> _processRecentStats(Map<String, dynamic> scores) {
    final runs = _parseNumberList(scores['runs']);
    final wickets = _parseNumberList(scores['wickets']);
    final balls = _parseNumberList(scores['balls']);
    final lastFour = _parseNumberList(scores['lastfour']);

    return {
      'Last Match Runs': _lastOrNA(runs),
      'Last Wickets': _lastOrNA(wickets),
      'Balls Faced': _lastOrNA(balls),
      'Strike Rate': _calculateStrikeRate(runs, balls),
      '4-Match Avg': _calculateAverage(lastFour),
      '4-Match High': _findMax(lastFour),
    };
  }

  Map<String, String> _processYearStats(Map<String, dynamic> scores) {
    final runs = _parseNumberList(scores['runs']);
    final wickets = _parseNumberList(scores['wickets']);
    final balls = _parseNumberList(scores['balls']);
    final innings = _parseNumberList(scores['innings']);

    return {
      'Total Runs': _sumValues(runs),
      'Total Wickets': _sumValues(wickets),
      'Matches': _countValidEntries(innings),
      'Average': _calculateAverage(runs),
      'Strike Rate': _calculateStrikeRate(runs, balls),
      'Centuries': _countCenturies(runs),
      'Half-Centuries': _countFifties(runs),
      'Highest Score': _findMax(runs),
    };
  }

  Map<String, String> _processCareerStats(Map<String, dynamic> career) {
    final runs = _parseNumberList(career['runs']);
    final wickets = _parseNumberList(career['wickets']);
    final balls = _parseNumberList(career['balls']);
    final innings = _parseNumberList(career['innings']);

    return {
      'Career Runs': _sumValues(runs),
      'Career Wickets': _sumValues(wickets),
      'Total Matches': _countValidEntries(innings),
      'Batting Avg': _calculateAverage(runs),
      'Strike Rate': _calculateStrikeRate(runs, balls),
      '100s': _countCenturies(runs),
      '50s': _countFifties(runs),
      'Best Score': _findMax(runs),
      'Intl Ranking': career['ranking']?.toString() ?? 'N/A',
    };
  }

  // ### Helper Functions
  List<num> _parseNumberList(dynamic data) {
    if (data is! List) return [];
    return data.whereType<String>().map((e) {
      try {
        return num.parse(e);
      } catch (_) {
        return 0;
      }
    }).toList();
  }

  String _sumValues(List<num> values) {
    if (values.isEmpty) return 'N/A';
    return values.fold<num>(0, (a, b) => a + b).toString();
  }

  String _calculateAverage(List<num> values) {
    if (values.isEmpty) return 'N/A';
    final validValues = values.where((v) => v > 0).toList();
    if (validValues.isEmpty) return 'N/A';
    return (validValues.reduce((a, b) => a + b) / validValues.length)
        .toStringAsFixed(2);
  }

  String _calculateStrikeRate(List<num> runs, List<num> balls) {
    if (runs.isEmpty || balls.isEmpty) return 'N/A';
    final totalRuns = runs.fold<num>(0, (a, b) => a + b);
    final totalBalls = balls.fold<num>(0, (a, b) => a + (b > 0 ? b : 1));
    return (totalRuns / totalBalls * 100).toStringAsFixed(2);
  }

  String _countCenturies(List<num> runs) {
    return runs.where((r) => r >= 100).length.toString();
  }

  String _countFifties(List<num> runs) {
    return runs.where((r) => r >= 50 && r < 100).length.toString();
  }

  String _findMax(List<num> values) {
    if (values.isEmpty) return 'N/A';
    return values.reduce((a, b) => a > b ? a : b).toString();
  }

  String _lastOrNA(List<num> values) =>
      values.isNotEmpty ? values.last.toString() : 'N/A';

  String _countValidEntries(List<num> values) =>
      values.where((v) => v > 0).length.toString();

  ImageProvider _getImageProvider(Map<String, dynamic> player) {
    try {
      final image = player['image']?.toString() ?? '';
      if (image.isEmpty) throw Error();
      final base64 = image.split(',').last;
      return MemoryImage(base64Decode(base64));
    } catch (_) {
      return const AssetImage('assets/players/default_profile.png');
    }
  }

  String _parseDate(String? date) {
    try {
      return date == null
          ? 'N/A'
          : DateFormat('dd MMM yyyy').format(DateTime.parse(date));
    } catch (_) {
      return 'N/A';
    }
  }
}

// ### Sticky Tab Delegate
class _StickyTabDelegate extends SliverPersistentHeaderDelegate {
  final List<String> tabs;
  final ThemeData theme;
  final TabController controller;

  _StickyTabDelegate(
      {required this.tabs, required this.theme, required this.controller});

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: theme.scaffoldBackgroundColor,
      child: TabBar(
        controller: controller,
        tabs: tabs.map((title) => Tab(text: title)).toList(),
        labelColor: theme.primaryColor,
        unselectedLabelColor: Colors.grey,
        indicatorColor: theme.primaryColor,
        padding: const EdgeInsets.symmetric(horizontal: 16),
      ),
    );
  }

  @override
  double get maxExtent => 48;

  @override
  double get minExtent => 48;

  @override
  bool shouldRebuild(_StickyTabDelegate oldDelegate) => false;
}
