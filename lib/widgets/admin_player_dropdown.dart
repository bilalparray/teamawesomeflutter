import 'package:flutter/material.dart';

class AdminPlayerDropdown extends StatelessWidget {
  const AdminPlayerDropdown({
    super.key,
    required this.players,
    required this.value,
    required this.onChanged,
    this.label = 'Select player',
  });

  final List<Map<String, dynamic>> players;
  final String? value;
  final ValueChanged<String?> onChanged;
  final String label;

  @override
  Widget build(BuildContext context) {
    final sorted = List<Map<String, dynamic>>.from(players)
      ..sort((a, b) =>
          (a['name']?.toString() ?? '').compareTo(b['name']?.toString() ?? ''));

    return DropdownButtonFormField<String>(
      initialValue: value,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      items: sorted
          .map(
            (p) => DropdownMenuItem<String>(
              value: p['_id']?.toString(),
              child: Text(p['name']?.toString() ?? 'Unknown'),
            ),
          )
          .toList(),
      onChanged: onChanged,
    );
  }
}
