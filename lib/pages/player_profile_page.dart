import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

const Map<String, IconData> statIcons = {
  'Last Runs': Icons.run_circle,
  'Last Wkts': Icons.sports_baseball,
  'Strike%': Icons.speed,
  'Avg 4': Icons.trending_up,
  'High 4': Icons.insights,
  'Total Runs': Icons.emoji_events,
  'Total Wkts': Icons.workspace_premium,
  'Matches': Icons.event_available,
  'Avg': Icons.calculate,
  'Career Runs': Icons.history_edu,
  'Career Wkts': Icons.history,
  'Rank': Icons.leaderboard,
  '50s': Icons.looks_5,
  '100s': Icons.looks_one,
  'Best': Icons.workspace_premium,
  'Balls': Icons.sports_baseball,
  'Match': Icons.sports_cricket,
  'Runs': Icons.directions_run,
  'Wickets': Icons.star,
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
  final double _appBarMaxHeight = 450;
  final double _appBarMinHeight = kToolbarHeight + 10;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    if (_tabController.index != 0) {
      _tabController.animateTo(0);
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final player = widget.player;

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            SliverAppBar(
              expandedHeight: _appBarMaxHeight,
              collapsedHeight: _appBarMinHeight,
              pinned: true,
              floating: true,
              stretch: true,
              backgroundColor: colors.primary,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              title: AnimatedOpacity(
                opacity: innerBoxIsScrolled ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundImage: _getImageProvider(player),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      player['name'] ?? 'Player',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              flexibleSpace: FlexibleSpaceBar(
                collapseMode: CollapseMode.parallax,
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
                            colors.primary.withOpacity(0.8),
                            Colors.transparent,
                            colors.primary.withOpacity(0.6),
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
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(48),
                child: Container(
                  alignment: Alignment.centerLeft,
                  color: colors.primary,
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
                    physics: const ClampingScrollPhysics(),
                    tabAlignment: TabAlignment.start,
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
            ),
          ],
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildTabContent(_buildProfileSection(player)),
              _buildTabContent(_buildStatsGrid(
                  _processRecentScores(player['scores'] ?? {}))),
              _buildTabContent(
                  _buildStatsGrid(_processYearScores(player['scores'] ?? {}))),
              _buildTabContent(_buildStatsGrid(
                  _processCareerScores(player['scores']?['career'] ?? {}))),
              _buildTabContent(
                  _buildStatsGrid(_processRunsScores(player['scores'] ?? {}))),
              _buildTabContent(_buildStatsGrid(
                  _processWicketsScores(player['scores'] ?? {}))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent(Widget content) {
    return CustomScrollView(
      slivers: [
        SliverList(
          delegate: SliverChildListDelegate([content]),
        ),
        SliverToBoxAdapter(
          child: SizedBox(height: MediaQuery.of(context).size.height * 0.5),
        ),
      ],
    );
  }

  Widget _buildProfileSection(Map<String, dynamic> player) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Column(
        children: [
          _buildProfileTile('Born', _parseDate(player['born']), Icons.cake),
          _buildProfileTile('Debut', _parseDate(player['debut']), Icons.flag),
          _buildProfileTile(
              'Batting Style', player['battingstyle'], Icons.sports_baseball),
          _buildProfileTile(
              'Bowling Style', player['bowlingstyle'], Icons.sports_cricket),
          _buildProfileTile('Role', player['role'], Icons.person),
        ],
      ),
    );
  }

  Widget _buildProfileTile(String title, String? value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(title,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: Colors.grey[600])),
        subtitle: Text(value ?? 'N/A',
            style: Theme.of(context).textTheme.titleMedium),
        contentPadding: EdgeInsets.zero,
      ),
    );
  }

  Widget _buildStatsGrid(Map<String, String> stats) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.4,
      ),
      itemCount: stats.length,
      itemBuilder: (context, index) {
        final entry = stats.entries.elementAt(index);
        return _statCard(entry.key, entry.value);
      },
    );
  }

  Widget _statCard(String title, String value) {
    final theme = Theme.of(context);
    final icon = statIcons[title] ?? Icons.help;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 24, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(title,
                    style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7))),
              ],
            ),
            const SizedBox(height: 8),
            Text(value,
                style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary)),
          ],
        ),
      ),
    );
  }

  Map<String, String> _processRecentScores(Map<String, dynamic> scores) {
    final runs = _toNumList(scores['runs']);
    final wkts = _toNumList(scores['wickets']);
    final balls = _toNumList(scores['balls']);
    final lastRuns = runs.isNotEmpty ? runs.last : 0;
    final lastWkts = wkts.isNotEmpty ? wkts.last : 0;
    final lastBalls = balls.isNotEmpty ? balls.last : 0;
    return {
      'Runs': lastRuns.toString(),
      'Wickets': lastWkts.toString(),
      'Strike%': _strikeRate([lastRuns], [lastBalls]),
      'Balls': lastBalls.toString(),
    };
  }

  Map<String, String> _processYearScores(Map<String, dynamic> scores) {
    final runs = _toNumList(scores['runs']);
    final wkts = _toNumList(scores['wickets']);
    final balls = _toNumList(scores['balls']);
    final fifties = runs.where((r) => r >= 50 && r < 100).length;
    final hundreds = runs.where((r) => r >= 100).length;
    return {
      'Total Runs': _sum(runs),
      'Total Wkts': _sum(wkts),
      'Matches': runs.length.toString(),
      'Avg': _average(runs),
      'Strike%': _strikeRate(runs, balls),
      '50s': fifties.toString(),
      '100s': hundreds.toString(),
      'Best': _max(runs),
      'Balls': _sum(balls),
    };
  }

  Map<String, String> _processCareerScores(Map<String, dynamic> career) {
    final runs = _toNumList(career['runs']);
    final wkts = _toNumList(career['wickets']);
    final balls = _toNumList(career['balls']);
    final fifties = runs.where((r) => r >= 50 && r < 100).length;
    final hundreds = runs.where((r) => r >= 100).length;
    return {
      'Rank': career['ranking'].toString(),
      'Career Runs': _sum(runs),
      'Career Wkts': _sum(wkts),
      'Matches': runs.length.toString(),
      'Avg': _average(runs),
      'Strike%': _strikeRate(runs, balls),
      '50s': fifties.toString(),
      '100s': hundreds.toString(),
      'Best': _max(runs),
      'Balls': _sum(balls),
    };
  }

  Map<String, String> _processRunsScores(Map<String, dynamic> scores) {
    final runs = _toNumList(scores['runs']);
    return {
      for (var i = runs.length - 1; i >= 0; i--)
        'Match ${i + 1}': runs[i].toString()
    };
  }

  Map<String, String> _processWicketsScores(Map<String, dynamic> scores) {
    final wkts = _toNumList(scores['wickets']);
    return {
      for (var i = wkts.length - 1; i >= 0; i--)
        'Match ${i + 1}': wkts[i].toString()
    };
  }

  List<num> _toNumList(dynamic data) => data is List
      ? data.whereType<String>().map((s) => num.tryParse(s) ?? 0).toList()
      : <num>[];

  String _sum(List<num> v) =>
      v.isEmpty ? '0' : v.fold<num>(0, (a, b) => a + b).toString();
  String _average(List<num> v) => v.isEmpty
      ? 'N/A'
      : (v.reduce((a, b) => a + b) / v.length).toStringAsFixed(2);
  String _strikeRate(List<num> runs, List<num> balls) {
    final totalRuns = runs.fold<double>(0, (a, b) => a + b);
    final totalBalls = balls.fold<double>(0, (a, b) => a + b);
    return (totalRuns == 0 || totalBalls == 0)
        ? 'N/A'
        : ((totalRuns / totalBalls) * 100).toStringAsFixed(2);
  }

  String _max(List<num> v) =>
      v.isEmpty ? 'N/A' : v.reduce((a, b) => a > b ? a : b).toString();

  ImageProvider _getImageProvider(Map<String, dynamic> player) {
    final img = player['image']?.toString() ?? '';
    if (img.isEmpty) return const AssetImage('assets/players/profile.png');
    return NetworkImage(img);
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
