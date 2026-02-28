import 'package:flutter/material.dart';
import 'package:arsii_mvp/screens/settings_detail_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _SettingsHeader(),
        const SizedBox(height: 12),
        _ExpandableSection(
          title: 'System Configuration',
          subtitle: 'Core app behavior and preferences',
          items: const [
            _SettingItem('General Settings', Icons.settings, 'Language, timezone, formats'),
            _SettingItem('Security & Privacy', Icons.shield, 'Permissions and access control'),
            _SettingItem('Notifications', Icons.notifications_none, 'Alerts, email, and push'),
          ],
        ),
        const SizedBox(height: 16),
        _ExpandableSection(
          title: 'User Management',
          subtitle: 'Teams, roles, and access',
          items: const [
            _SettingItem('Roles & Permissions', Icons.admin_panel_settings, 'Define access levels'),
            _SettingItem('User Preferences', Icons.person_outline, 'Default preferences'),
            _SettingItem('Directory Sync', Icons.sync, 'Import users and teams'),
          ],
        ),
        const SizedBox(height: 16),
        _ExpandableSection(
          title: 'Data & Storage',
          subtitle: 'Data management and export',
          items: const [
            _SettingItem('Backup & Restore', Icons.cloud_upload, 'Restore from snapshot'),
            _SettingItem('Export Reports', Icons.file_download, 'CSV and PDF exports'),
            _SettingItem('Retention Policy', Icons.delete_sweep, 'Auto clean-up rules'),
          ],
        ),
      ],
    );
  }
}

class _SettingsHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1F2A44),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.settings, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text('Settings', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
              SizedBox(height: 4),
              Text('Configure your workspace', style: TextStyle(color: Colors.white70)),
            ],
          ),
        ],
      ),
    );
  }
}

class _ExpandableSection extends StatefulWidget {
  final String title;
  final String subtitle;
  final List<_SettingItem> items;

  const _ExpandableSection({required this.title, required this.subtitle, required this.items});

  @override
  State<_ExpandableSection> createState() => _ExpandableSectionState();
}

class _ExpandableSectionState extends State<_ExpandableSection> {
  bool _open = true;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          ListTile(
            title: Text(widget.title, style: Theme.of(context).textTheme.titleMedium),
            subtitle: Text(widget.subtitle),
            trailing: Icon(_open ? Icons.expand_less : Icons.expand_more),
            onTap: () => setState(() => _open = !_open),
          ),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 200),
            crossFadeState: _open ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Column(
                children: [
                  for (final item in widget.items)
                    ListTile(
                      dense: true,
                      leading: Icon(item.icon, color: const Color(0xFF1F2A44)),
                      title: Text(item.title),
                      subtitle: Text(item.subtitle),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => SettingsDetailScreen(
                              title: item.title,
                              rows: [
                                SettingRow(
                                  title: '${item.title} - Option 1',
                                  subtitle: 'Configure details and preferences',
                                  icon: item.icon,
                                ),
                                SettingRow(
                                  title: '${item.title} - Option 2',
                                  subtitle: 'Advanced configuration',
                                  icon: item.icon,
                                ),
                                SettingRow(
                                  title: '${item.title} - Option 3',
                                  subtitle: 'System defaults',
                                  icon: item.icon,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingItem {
  final String title;
  final IconData icon;
  final String subtitle;
  const _SettingItem(this.title, this.icon, this.subtitle);
}
