import 'package:flutter/material.dart';
import 'player_data_processor.dart';

const Map<String, IconData> statIcons = {
  'Last Runs': Icons.sports_cricket, // what happened most recently
  'Last Wkts':
      Icons.sports_baseball, // last wickets are a cricket-specific event
  'Strike%': Icons.show_chart, // percentage → chart
  'Avg 4': Icons.bar_chart, // average of 4s → bar chart
  'High 4': Icons.trending_up, // highest number of 4s → trending up
  'Total Runs': Icons.stacked_line_chart, // totals over time
  'Total Wkts': Icons.sports_baseball, // total wickets → outlined cricket icon
  'Matches': Icons.event, // count of match events
  'Avg': Icons.calculate, // average → calculator
  'Career Runs': Icons.sports_cricket, // career long history
  'Career Wkts': Icons.sports_baseball, // career skill (school)
  'Rank': Icons.emoji_events, // ranking
  '50s': Icons.filter_5, // “5” styled icon
  '100s': Icons.filter_1, // “1” styled icon (for 100)
  'Best': Icons.emoji_events, // best performance → trophy
  'Balls': Icons.sports_baseball, // cricket ball
  'Match': Icons.sports_cricket, // a match is cricket
  'Runs': Icons.sports_cricket, // running between the wickets
  'Wickets': Icons.sports_baseball, // wicket icon
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
                            colors.primary.withValues(alpha: 0.9),
                            Colors.transparent,
                            colors.primary.withValues(alpha: 0.9),
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
                  PlayerDataProcessor.processRecentScores(
                      player['scores'] ?? {}))),
              _buildTabContent(_buildStatsGrid(
                  PlayerDataProcessor.processYearScores(
                      player['scores'] ?? {}))),
              _buildTabContent(_buildStatsGrid(
                  PlayerDataProcessor.processCareerScores(
                      player['scores']?['career'] ?? {}))),
              _buildTabContent(_buildStatsGrid(
                  PlayerDataProcessor.processRunsScores(
                      player['scores'] ?? {}))),
              _buildTabContent(_buildStatsGrid(
                  PlayerDataProcessor.processWicketsScores(
                      player['scores'] ?? {}))),
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
          _buildProfileTile('Born',
              PlayerDataProcessor.parseDate(player['born']), Icons.cake),
          _buildProfileTile('Debut',
              PlayerDataProcessor.parseDate(player['debut']), Icons.flag),
          _buildProfileTile(
              'Batting Style', player['battingstyle'], Icons.sports_cricket),
          _buildProfileTile(
              'Bowling Style', player['bowlingstyle'], Icons.sports_baseball),
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
                        color: theme.colorScheme.onSurface
                            .withValues(alpha: 0.9))),
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

  ImageProvider _getImageProvider(Map<String, dynamic> player) {
    final img = player['image']?.toString() ?? '';
    if (img.isEmpty) return const AssetImage('assets/players/profile.png');
    return NetworkImage(img);
  }
}
