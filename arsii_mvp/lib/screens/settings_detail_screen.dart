import 'package:flutter/material.dart';

class SettingsDetailScreen extends StatelessWidget {
  final String title;
  final List<SettingRow> rows;

  const SettingsDetailScreen({super.key, required this.title, required this.rows});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          for (final row in rows)
            Card(
              child: ListTile(
                leading: Icon(row.icon, color: const Color(0xFF1F2A44)),
                title: Text(row.title),
                subtitle: Text(row.subtitle),
                trailing: const Icon(Icons.chevron_right),
                onTap: row.onTap,
              ),
            ),
        ],
      ),
    );
  }
}

class SettingRow {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback? onTap;

  const SettingRow({
    required this.title,
    required this.subtitle,
    required this.icon,
    this.onTap,
  });
}
