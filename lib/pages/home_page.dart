import 'package:flutter/material.dart';
import 'package:teamawesomesozeith/main.dart';
import '../services/player_service.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/hero_header.dart';
import '../widgets/man_of_the_match_card.dart';
import '../widgets/featured_players_list.dart';
import '../widgets/home_skeleton_loader.dart';
import '../widgets/management_card_widget.dart'; // Import your ManagementCardWidget
import 'settings_page.dart';

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
    if (errorMessage.isNotEmpty) {
      return Scaffold(
        appBar: CustomAppBar(title: const Text('Team Awesome Sozeith')),
        body: Center(child: Text(errorMessage)),
      );
    }

    return Scaffold(
      appBar: CustomAppBar(
        title: const Text('Team Awesome Sozeith'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => SettingsPage()),
            ),
          ),
        ],
      ),
      body: isLoading ? const HomeSkeletonLoader() : _buildPlayerContent(),
    );
  }

  Widget _buildPlayerContent() {
    final motm = PlayerService.manOfTheMatch;

    return ListView(
      padding: const EdgeInsets.only(bottom: 80),
      children: [
        const HeroHeader(),
        if (motm != null) ManOfTheMatchCard(player: motm),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Featured Players',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        const FeaturedPlayersList(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Management Body',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        // Example usage of the ManagementCardWidget
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: ManagementCardWidget(
            imagePath:
                'https://media.cricheroes.in/user_profile/1679455036216_FZVApXPFT0zj.jpg?width=1920&quality=75&format=auto',
            title: 'Umer',
            role: 'Coach',
            description:
                'I guide and train the team, helping each player improve their skills.',
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: ManagementCardWidget(
            imagePath:
                'https://media.cricheroes.in/user_profile/1644751225184_kGI4TIBJkvxS.jpg?width=1920&quality=75&format=auto',
            title: 'Ahsaan ul Haq',
            role: 'Captain',
            description:
                'I lead by example on the field. I make quick decisions.',
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: ManagementCardWidget(
            imagePath:
                'https://media.cricheroes.in/user_profile/1655743891306_TpqUnn0bpI0K.jpg?width=1920&quality=75&format=auto',
            title: 'Owais',
            role: 'Manager',
            description:
                'I handle the team’s overall planning and coordination. I make sure everything runs smoothly.',
          ),
        ),
      ],
    );
  }
}
