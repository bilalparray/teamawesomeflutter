import 'package:flutter/material.dart';
import 'package:teamawesomesozeith/pages/admin/admin_add_match_page.dart';
import 'package:teamawesomesozeith/pages/admin/admin_add_player_page.dart';
import 'package:teamawesomesozeith/pages/admin/admin_batting_order_page.dart';
import 'package:teamawesomesozeith/pages/admin/admin_mate_turn_page.dart';
import 'package:teamawesomesozeith/pages/admin/admin_scorecard_page.dart';
import 'package:teamawesomesozeith/pages/admin/admin_update_last_page.dart';
import 'package:teamawesomesozeith/pages/admin/admin_update_player_page.dart';
import 'package:teamawesomesozeith/pages/admin/admin_update_scores_page.dart';
import 'package:teamawesomesozeith/pages/admin/admin_update_wicket_page.dart';
import 'package:teamawesomesozeith/services/admin/admin_auth_service.dart';

class AdminHubPage extends StatelessWidget {
  const AdminHubPage({super.key});

  Future<void> _logout(BuildContext context) async {
    await AdminAuthService.logout();
    if (context.mounted) Navigator.of(context).pop();
  }

  void _open(BuildContext context, Widget page) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Team Admin'),
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: 'Log out',
            onPressed: () => _logout(context),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Admin tools',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Full team management — same tools as the web admin panel.',
            style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
          ),
          const SizedBox(height: 20),
          _sectionTitle('Players & scores'),
          _AdminTile(
            icon: Icons.person_add_alt_1,
            title: 'Add Player',
            subtitle: 'Register a new squad member',
            color: const Color(0xFF1565C0),
            onTap: () => _open(context, const AdminAddPlayerPage()),
          ),
          const SizedBox(height: 12),
          _AdminTile(
            icon: Icons.scoreboard,
            title: 'Update Runs',
            subtitle: 'Append runs, balls, and wickets',
            color: const Color(0xFF00838F),
            onTap: () => _open(context, const AdminUpdateScoresPage()),
          ),
          const SizedBox(height: 12),
          _AdminTile(
            icon: Icons.sports_cricket,
            title: 'Update Wickets',
            subtitle: 'Add wickets for a bowler',
            color: const Color(0xFF6A1B9A),
            onTap: () => _open(context, const AdminUpdateWicketPage()),
          ),
          const SizedBox(height: 12),
          _AdminTile(
            icon: Icons.history,
            title: 'Update Last Slot',
            subtitle: 'Fix the most recent innings entry',
            color: const Color(0xFF4527A0),
            onTap: () => _open(context, const AdminUpdateLastPage()),
          ),
          const SizedBox(height: 12),
          _AdminTile(
            icon: Icons.badge,
            title: 'Update Player Profile',
            subtitle: 'Edit name, role, styles, and photo',
            color: const Color(0xFF283593),
            onTap: () => _open(context, const AdminUpdatePlayerPage()),
          ),
          const SizedBox(height: 24),
          _sectionTitle('Matches & processing'),
          _AdminTile(
            icon: Icons.event,
            title: 'Next Match',
            subtitle: 'Add, edit, or delete fixtures',
            color: const Color(0xFFAD1457),
            onTap: () => _open(context, const AdminAddMatchPage()),
          ),
          const SizedBox(height: 12),
          _AdminTile(
            icon: Icons.format_list_numbered,
            title: 'Batting Order',
            subtitle: 'Calculate and post new batting order',
            color: const Color(0xFF2E7D32),
            onTap: () => _open(context, const AdminBattingOrderPage()),
          ),
          const SizedBox(height: 12),
          _AdminTile(
            icon: Icons.picture_as_pdf_rounded,
            title: 'Scorecard Processor',
            subtitle: 'Extract PDF stats and apply to database',
            color: theme.colorScheme.primary,
            onTap: () => _open(context, const AdminScorecardPage()),
          ),
          const SizedBox(height: 12),
          _AdminTile(
            icon: Icons.local_cafe_rounded,
            title: 'Mate Turn',
            subtitle: 'Configure groups and record weekly mate',
            color: const Color(0xFFE65100),
            onTap: () => _open(context, const AdminMateTurnPage()),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 13,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _AdminTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _AdminTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
