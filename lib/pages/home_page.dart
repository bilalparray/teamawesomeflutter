import 'package:flutter/material.dart';
import 'package:teamawesomesozeith/main.dart';
import 'package:teamawesomesozeith/services/match_service.dart';
import 'package:teamawesomesozeith/widgets/match_card.dart';
import 'package:teamawesomesozeith/widgets/topper_widget.dart';
import '../services/player_service.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/man_of_the_match_card.dart';
import '../widgets/featured_players_list.dart';
import '../widgets/home_skeleton_loader.dart';
import '../widgets/management_card_widget.dart'; // Import your ManagementCardWidget
import '../widgets/section_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isLoading = true;
  String errorMessage = '';
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);
    try {
      await PlayerService.fetchPlayers(forceRefresh: true);
      await MatchService.fetchMatches(forceRefresh: true);
      setState(() => isLoading = false);
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
      ApiErrorNotification().dispatch(context);
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (errorMessage.isNotEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Team Awesome Sozeith'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline,
                    size: 40,
                    color: Theme.of(context).colorScheme.error),
                const SizedBox(height: 12),
                Text(
                  'Something went wrong',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  errorMessage,
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: Colors.grey[700]),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _loadData,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Team Awesome Sozeith'),
      ),
      body: isLoading
          ? const HomeSkeletonLoader()
          : RefreshIndicator(
              onRefresh: _loadData,
              child: _buildPlayerContent(),
            ),
    );
  }

  Widget _buildPlayerContent() {
    final motm = PlayerService.manOfTheMatch;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
      children: [
        SectionCard(
          leading: CircleAvatar(
            radius: 20,
            backgroundColor:
                Theme.of(context).colorScheme.primary.withOpacity(0.1),
            child: Icon(
              Icons.shield_moon_rounded,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          title: 'Team Awesome Sozeith',
          subtitle:
              'A passionate local cricket team from Sozeith, known for teamwork and energy.',
        ),
        if (motm != null) ...[
          const SizedBox(height: 12),
          SectionCard(
            leading: Icon(
              Icons.emoji_events_rounded,
              color: Theme.of(context).colorScheme.primary,
            ),
            title: 'Man of the Match',
            subtitle: 'Latest standout performance for the team.',
            child: ManOfTheMatchCard(player: motm),
          ),
        ],
        const SizedBox(height: 12),
        SectionCard(
          leading: Icon(
            Icons.groups_rounded,
            color: Theme.of(context).colorScheme.primary,
          ),
          title: 'Featured Players',
          subtitle: 'Key players making an impact this season.',
          child: const FeaturedPlayersList(),
        ),
        const SizedBox(height: 12),
        SectionCard(
          leading: Icon(
            Icons.manage_accounts_rounded,
            color: Theme.of(context).colorScheme.primary,
          ),
          title: 'Team Management',
          subtitle: 'Leaders guiding and supporting the squad.',
          child: Column(
            children: const [
              ManagementCardWidget(
                imagePath: 'assets/players/umer.jpg',
                title: 'Umer Raja',
                role: 'Coach',
                description: 'I guide and train the team.',
                url:
                    'https://cricheroes.com/player-profile/5250770/umer-raja/matches',
              ),
              SizedBox(height: 12),
              ManagementCardWidget(
                imagePath: 'assets/players/ehsaan.jpg',
                title: 'Ahsaan ul Haq',
                role: 'Captain',
                description: 'I lead by example on the field.',
              ),
              SizedBox(height: 12),
              ManagementCardWidget(
                imagePath: 'assets/players/owais.jpg',
                title: 'Owais Farooq',
                role: 'Manager',
                description: 'I handle the team’s overall planning.',
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SectionCard(
          leading: Icon(
            Icons.sports_cricket_rounded,
            color: Theme.of(context).colorScheme.primary,
          ),
          title: 'Top Run Scorer (${DateTime.now().year})',
          subtitle: 'Most total runs scored across recorded matches.',
          child: _buildTopScorer(),
        ),
        const SizedBox(height: 12),
        SectionCard(
          leading: Icon(
            Icons.sports_baseball_rounded,
            color: Theme.of(context).colorScheme.primary,
          ),
          title: 'Top Wicket Taker (${DateTime.now().year})',
          subtitle: 'Highest wicket taker with the ball.',
          child: _buildTopWicketTaker(),
        ),
        const SizedBox(height: 12),
        SectionCard(
          leading: Icon(
            Icons.calendar_month_rounded,
            color: Theme.of(context).colorScheme.primary,
          ),
          title: 'Recent Matches',
          subtitle: 'Latest fixtures and results for the team.',
          child: _buildMatchDetails(),
        ),
      ],
    );
  }

  Widget _buildTopScorer() {
    final players = PlayerService.players;

    if (players.isEmpty) {
      return const Text('No players found');
    }

    dynamic topScorer;
    int maxRuns = 0;

    for (var player in players) {
      final scores = player['scores'];
      if (scores == null || scores['runs'] == null) continue;

      final runsList = scores['runs'] as List<dynamic>;

      // Convert string runs to int and sum them
      int totalRuns = runsList
          .map((run) => int.tryParse(run.toString()) ?? 0)
          .fold(0, (sum, run) => sum + run);

      if (totalRuns > maxRuns) {
        maxRuns = totalRuns;
        topScorer = player;
      }
    }

    if (topScorer == null) {
      return const Text('No valid top scorer found');
    }

    return TopperCard(
      imagePath: topScorer['image'] ?? '',
      playerName: topScorer['name'] ?? 'Unknown',
      runsScored: maxRuns,
      wicket: null, // or parse from topScorer['scores']['wickets'] if needed
    );
  }

  Widget _buildTopWicketTaker() {
    final players = PlayerService.players;

    if (players.isEmpty) return const Text('No players found');

    dynamic topPlayer;
    int topWickets = 0;

    for (var player in players) {
      final scores = player['scores'];
      if (scores == null || scores['wickets'] == null) continue;

      final totalWickets = (scores['wickets'] as List<dynamic>)
          .map((w) => int.tryParse(w.toString()) ?? 0)
          .fold(0, (a, b) => a + b);

      if (totalWickets > topWickets) {
        topWickets = totalWickets;
        topPlayer = player;
      }
    }

    if (topPlayer == null) return const Text('No top wicket taker found');

    return TopperCard(
      imagePath: topPlayer['image'] ?? '',
      playerName: topPlayer['name'] ?? 'Unknown',
      runsScored: null,
      wicket: topWickets,
    );
  }

  // Required imports (place at top of your file where you paste this)
// import '../services/match_service.dart';
// import '../widgets/match_card.dart';

  Widget _buildMatchDetails() {
    final matches = MatchService.matches;

    if (matches.isEmpty) {
      return const Text('No matches found');
    }

    // Sort by date (newest first = LIFO). Null dates go to the end.
    final sorted = List.from(matches);
    sorted.sort((a, b) {
      final ad = a.date;
      final bd = b.date;
      if (ad == null && bd == null) return 0;
      if (ad == null) return 1; // put nulls at the end
      if (bd == null) return -1; // put nulls at the end
      return bd.compareTo(ad); // reversed: newest first (LIFO)
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: List.generate(sorted.length, (index) {
        final m = sorted[index];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Small index/badge + status row (optional — remove if you don't want it)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text('#${index + 1}'),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      (m.status ?? '').toString().toUpperCase(),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),

            // The reusable MatchCard (expects a MatchModel)
            MatchCard(
              match: m,
            ),
          ],
        );
      }),
    );
  }
}
