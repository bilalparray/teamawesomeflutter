import 'package:flutter/material.dart';
import '../widgets/custom_app_bar.dart';

class PlayerProfilePage extends StatelessWidget {
  final Map<String, String> player;
  const PlayerProfilePage({super.key, required this.player});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: CustomAppBar(
          title: Text(player['name']!),
          actions: [],
        ),
        body: Padding(
          padding: const EdgeInsets.only(bottom: 80),
          child: Column(
            children: [
              const SizedBox(height: 16),
              CircleAvatar(
                backgroundImage: AssetImage(player['image']!),
                radius: 50,
              ),
              const SizedBox(height: 12),
              Text(
                player['role']!,
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              // stats tabs
              TabBar(
                indicatorColor: Colors.green,
                labelColor: Colors.green[800],
                unselectedLabelColor: Colors.grey,
                tabs: const [
                  Tab(text: 'This Year'),
                  Tab(text: 'Career'),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    _statsTable(
                        {'Matches': '10', 'Runs': '450', 'Wickets': '12'}),
                    _statsTable(
                        {'Matches': '75', 'Runs': '2890', 'Wickets': '102'}),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
