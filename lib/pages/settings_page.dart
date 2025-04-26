import 'package:flutter/material.dart';
import '../widgets/custom_app_bar.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: Text('Settings')),
      body: const Center(child: Text('Settings coming soon!')),
    );
  }
}
