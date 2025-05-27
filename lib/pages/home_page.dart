import 'package:flutter/material.dart';
import 'package:teamawesomesozeith/main.dart';
import 'package:teamawesomesozeith/widgets/topper_widget.dart';
import '../services/player_service.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/hero_header.dart';
import '../widgets/man_of_the_match_card.dart';
import '../widgets/featured_players_list.dart';
import '../widgets/home_skeleton_loader.dart';
import '../widgets/management_card_widget.dart'; // Import your ManagementCardWidget

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
      await PlayerService.fetchPlayers();
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
    final theme = Theme.of(context);
    if (errorMessage.isNotEmpty) {
      return Scaffold(
        appBar: CustomAppBar(title: const Text('Team Awesome Sozeith')),
        body: Center(child: Text(errorMessage)),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.primaryColor,
        title: const Text(
          'Team Awesome Sozeith',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        // actions: [
        //   IconButton(
        //     icon: const Icon(Icons.settings_outlined),
        //     color: Colors.white,
        //     onPressed: () => Navigator.push(
        //       context,
        //       MaterialPageRoute(builder: (_) => SettingsPage()),
        //     ),
        //   ),
        // ],
      ),
      body: isLoading ? const HomeSkeletonLoader() : _buildPlayerContent(),
    );
  }

  Widget _buildPlayerContent() {
    final motm = PlayerService.manOfTheMatch;

    return ListView(
      padding: const EdgeInsets.only(bottom: 80),
      children: [
        const HeroHeader(
          teamName: 'Team Awesome Sozeith',
          description:
              'A passionate local cricket team from Sozeith, known for teamwork and energy!',
        ),

        if (motm != null) ManOfTheMatchCard(player: motm),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Row(
            children: [
              const Icon(Icons.groups,
                  color: Color.fromARGB(255, 13, 165, 170)),
              Text(
                ' Featured Players',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: const Color.fromARGB(255, 13, 165, 170),
                    ),
              ),
            ],
          ),
        ),
        const FeaturedPlayersList(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Row(
            children: [
              const Icon(Icons.groups,
                  color: Color.fromARGB(255, 13, 165, 170)),
              Text(
                ' Management',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: const Color.fromARGB(255, 13, 165, 170),
                    ),
              ),
            ],
          ),
        ),
        // Example usage of the ManagementCardWidget
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: ManagementCardWidget(
              imagePath: 'assets/players/umer.jpg',
              title: 'Umer Raja',
              role: 'Coach',
              description: 'I guide and train the team.',
              url:
                  'https://cricheroes.com/player-profile/5250770/umer-raja/matches'),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: ManagementCardWidget(
            imagePath: 'assets/players/ehsaan.jpg',
            title: 'Ahsaan ul Haq',
            role: 'Captain',
            description: 'I lead by example on the field.',
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: ManagementCardWidget(
            imagePath: 'assets/players/owais.jpg',
            title: 'Owais Farooq',
            role: 'Manager',
            description: 'I handle the team’s overall planning.',
          ),
        ),

        SizedBox(height: 6),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Row(
            children: [
              const Icon(Icons.sports_cricket,
                  color: Color.fromARGB(255, 13, 165, 170)),
              Text(
                ' Top Run Scorer (${DateTime.now().year})',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: const Color.fromARGB(255, 13, 165, 170),
                    ),
              ),
            ],
          ),
        ),
        SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _buildTopScorer(),
        ),
        SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Row(
            children: [
              const Icon(Icons.sports_baseball,
                  color: Color.fromARGB(255, 13, 165, 170)),
              Text(
                ' Top Wicket Taker (${DateTime.now().year})',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: const Color.fromARGB(255, 13, 165, 170),
                    ),
              ),
            ],
          ),
        ),

        SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _buildTopWicketTaker(),
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
}
