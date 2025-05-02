import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

const Map<String, IconData> statIcons = {
  'Last Runs': Icons.sports_cricket,
  'Last Wkts': Icons.sports_baseball,
  'Strike%': Icons.speed,
  'Avg 4': Icons.trending_up,
  'High 4': Icons.arrow_upward,
  'Total Runs': Icons.sports_cricket,
  'Total Wkts': Icons.sports_baseball,
  'Matches': Icons.event,
  'Avg': Icons.trending_up,
  'Career Runs': Icons.sports_cricket,
  'Career Wkts': Icons.sports_baseball,
  'Rank': Icons.star,
  '50s': Icons.sports_cricket,
  '100s': Icons.sports_cricket,
  'Best': Icons.sports_cricket,
  'Balls': Icons.sports_baseball,
  'Match': Icons.sports_cricket,
  'Runs': Icons.sports_cricket,
  'Wickets': Icons.sports_baseball,
};

class PlayerProfilePage extends StatefulWidget {
  final Map<String, dynamic> player;
  const PlayerProfilePage({super.key, required this.player});

  @override
  _PlayerProfilePageState createState() => _PlayerProfilePageState();
}

class _PlayerProfilePageState extends State<PlayerProfilePage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  double _opacity = 0.0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _opacity = 1.0;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.primaryColor;
    final player = widget.player;

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 400,
              pinned: true,
              floating: false, // Changed to false
              backgroundColor: primary,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              title: AnimatedOpacity(
                opacity: innerBoxIsScrolled ? 0.0 : 1.0,
                duration: const Duration(milliseconds: 200),
                child: Text(
                  player['name'] ?? 'Player Profile',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: const Color.fromARGB(255, 239, 239, 239),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              centerTitle: false,
              // In the SliverAppBar's bottom property
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(48),
                child: Container(
                  color: primary,
                  alignment: Alignment.centerLeft, // Force left alignment
                  child: TabBar(
                    controller: _tabController,
                    indicatorColor: Colors.white,
                    labelColor: Colors.white,
                    isScrollable: true,
                    unselectedLabelColor: Colors.white70,
                    labelStyle: theme.textTheme.titleMedium,
                    padding: EdgeInsets.zero,
                    indicatorPadding: EdgeInsets.zero,
                    labelPadding: const EdgeInsets.symmetric(horizontal: 16),
                    physics:
                        const ClampingScrollPhysics(), // Prevent overscroll glow
                    tabAlignment: TabAlignment.start, // Explicit left alignment
                    tabs: const [
                      Tab(text: 'Profile'),
                      Tab(text: 'Recent'),
                      Tab(text: 'Year'),
                      Tab(text: 'Career'),
                      Tab(text: 'Runs'),
                      Tab(text: 'Wickets'),
                    ],
                  ),
                ),
              ),
              flexibleSpace: FlexibleSpaceBar(
                collapseMode: CollapseMode.pin,
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image(
                      image: _getImageProvider(player),
                      fit: BoxFit.cover,
                      alignment: Alignment.topCenter,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.black.withOpacity(0.4),
                            Colors.transparent,
                            Colors.black.withOpacity(0.2),
                          ],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          stops: const [0.0, 0.5, 1.0],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ];
        },
        body: AnimatedOpacity(
          opacity: _opacity,
          duration: const Duration(milliseconds: 500),
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildProfileSection(player),
              _statsGrid(_processRecentScores(player['scores'] ?? {})),
              _statsGrid(_processYearScores(player['scores'] ?? {})),
              _statsGrid(
                  _processCareerScores(player['scores']?['career'] ?? {})),
              _statsGrid(_processRunsScores(player['scores'] ?? {})),
              _statsGrid(_processWicketsScores(player['scores'] ?? {})),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileSection(Map<String, dynamic> player) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                player['name'] ?? 'Unknown Player',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            const SizedBox(height: 24),
            _buildMetadataItem('Born', _parseDate(player['born']), Icons.cake),
            _buildMetadataItem(
                'Debut', _parseDate(player['debut']), Icons.sports_cricket),
            _buildMetadataItem('Batting Style', player['battingstyle'] ?? 'N/A',
                Icons.sports_handball),
            _buildMetadataItem('Bowling Style', player['bowlingstyle'] ?? 'N/A',
                Icons.sports_baseball),
            _buildMetadataItem('Role', player['role'] ?? 'N/A', Icons.person),
          ],
        ),
      ),
    );
  }

  Widget _buildMetadataItem(String label, String value, IconData icon) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).primaryColor, size: 24),
        title: Text(
          label,
          style: TextStyle(color: Colors.grey[600], fontSize: 14),
        ),
        trailing: Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
      ),
    );
  }

  Widget _statsGrid(Map<String, String> stats) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.6,
        children: stats.entries.map((e) => _statCard(e.key, e.value)).toList(),
      ),
    );
  }

  Widget _statCard(String title, String value) {
    final baseIcon = statIcons[title] ??
        (title.startsWith('Match') ? statIcons['Match'] : Icons.info);
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(baseIcon, color: Theme.of(context).primaryColor, size: 24),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Map<String, String> _processRecentScores(Map<String, dynamic> scores) {
    final runsList = _toNumList(scores['runs']);
    final wicketsList = _toNumList(scores['wickets']);
    final ballsList = _toNumList(scores['balls']);

    final lastRuns = runsList.isNotEmpty ? runsList.last : 0;
    final lastWickets = wicketsList.isNotEmpty ? wicketsList.last : 0;
    final lastBalls = ballsList.isNotEmpty ? ballsList.last : 0;

    return {
      'Runs': lastRuns.toString(),
      'Wickets': lastWickets.toString(),
      'Strike%': _strikeRate([lastRuns], [lastBalls]),
      'Balls': lastBalls.toString(),
    };
  }

  Map<String, String> _processYearScores(Map<String, dynamic> scores) {
    final runs = _toNumList(scores['runs']);
    final wickets = _toNumList(scores['wickets']);
    final balls = _toNumList(scores['balls']);
    final fifties = runs.where((r) => r >= 50 && r < 100).length;
    final hundreds = runs.where((r) => r >= 100).length;
    return {
      'Total Runs': _sum(runs),
      'Total Wkts': _sum(wickets),
      'Matches': runs.length.toString(),
      'Avg': _average(runs),
      'Strike%': _strikeRate(runs, balls),
      "50s": fifties.toString(),
      "100s": hundreds.toString(),
      'Best': _max(runs),
      'Balls': _sum(balls)
    };
  }

  Map<String, String> _processCareerScores(Map<String, dynamic> career) {
    final runs = _toNumList(career['runs']);
    final wickets = _toNumList(career['wickets']);
    final balls = _toNumList(career['balls']);
    final fifties = runs.where((r) => r >= 50 && r < 100).length;
    final hundreds = runs.where((r) => r >= 100).length;

    return {
      'Rank': career['ranking'].toString(),
      'Career Runs': _sum(runs),
      'Career Wkts': _sum(wickets),
      'Matches': runs.length.toString(),
      'Avg': _average(runs),
      'Strike%': _strikeRate(runs, balls),
      "50s": fifties.toString(),
      "100s": hundreds.toString(),
      'Best': _max(runs),
      'Balls': _sum(balls)
    };
  }

  Map<String, String> _processRunsScores(Map<String, dynamic> scores) {
    final runs = _toNumList(scores['runs']);
    final stats = <String, String>{};
    for (var i = runs.length - 1; i >= 0; i--) {
      stats['Match ${i + 1}'] = runs[i].toString();
    }
    return stats;
  }

  Map<String, String> _processWicketsScores(Map<String, dynamic> scores) {
    final wickets = _toNumList(scores['wickets']);
    final stats = <String, String>{};
    for (var i = 0; i < wickets.length; i++) {
      final matchNumber = wickets.length - i;
      stats['Match $matchNumber'] = wickets[i].toString();
    }
    return stats;
  }

  List<num> _toNumList(dynamic data) {
    if (data is! List) return [];
    return data.whereType<String>().map((s) => num.tryParse(s) ?? 0).toList();
  }

  String _sum(List<num> v) => v.fold<num>(0, (a, b) => a + b).toString();
  String _average(List<num> v) => v.isEmpty
      ? 'N/A'
      : (v.reduce((a, b) => a + b) / v.length).toStringAsFixed(2);
  String _strikeRate(List<num> runs, List<num> balls) {
    final totalRuns = runs.fold<double>(0.0, (sum, val) => sum + val);
    final totalBalls = balls.fold<double>(0.0, (sum, val) => sum + val);
    if (totalRuns == 0 || totalBalls == 0) return 'N/A';
    return ((totalRuns / totalBalls) * 100).toStringAsFixed(2);
  }

  // String _lastOrNA(List<num> v) => v.isNotEmpty ? v.last.toString() : 'N/A';
  String _max(List<num> v) =>
      v.isNotEmpty ? v.reduce((a, b) => a > b ? a : b).toString() : 'N/A';

  ImageProvider _getImageProvider(Map<String, dynamic> player) {
    try {
      final img = player['image']?.toString() ?? '';
      if (img.isEmpty) throw 'no image';
      return NetworkImage(img);
    } catch (_) {
      return const AssetImage('assets/players/profile.png');
    }
  }

  String _parseDate(String? date) {
    if (date == null) return 'N/A';
    try {
      return DateFormat('dd MMM yyyy').format(DateTime.parse(date));
    } catch (_) {
      return 'N/A';
    }
  }
}
