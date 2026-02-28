import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:arsii_mvp/state/providers.dart';
import 'package:arsii_mvp/models/enums.dart';
import 'package:arsii_mvp/widgets/task_list.dart';
import 'package:arsii_mvp/screens/notifications_screen.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  bool _engineeringOpen = true;
  bool _designOpen = false;

  @override
  Widget build(BuildContext context) {
    final asyncDash = ref.watch(dashboardProvider);

    return asyncDash.when(
      data: (dash) {
        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(dashboardProvider);
          },
          child: ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(16),
            children: [
              _TopBar(
                title: 'ARSII-Sfax',
                subtitle: dash.role.name,
                onNotifications: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const NotificationsScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              _StatGrid(
                items: [
                  _StatItem(
                    label: 'Total Tasks',
                    value: dash.totalTasks.toString(),
                    icon: Icons.group,
                    delta: '+12%',
                    color: const Color(0xFF10B981),
                  ),
                  _StatItem(
                    label: 'Active Projects',
                    value: dash.projectsSummary.values.fold<int>(0, (a, b) => a + b).toString(),
                    icon: Icons.folder,
                    delta: '+5',
                    color: const Color(0xFF3D7BEE),
                  ),
                  _StatItem(
                    label: 'Overdue',
                    value: dash.overdueTasks.toString(),
                    icon: Icons.warning_amber_rounded,
                    delta: '-2',
                    color: const Color(0xFFF59E0B),
                  ),
                  _StatItem(
                    label: 'Due Soon',
                    value: dash.dueSoonTasks.toString(),
                    icon: Icons.timer,
                    delta: '+3',
                    color: const Color(0xFFEF4444),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _SectionHeader(
                title: dash.role == Role.user ? 'My Tasks' : 'Team Tasks',
                action: 'View All',
              ),
              const SizedBox(height: 8),
              TaskList(tasks: dash.role == Role.user ? dash.myTasks : dash.teamTasks),
              const SizedBox(height: 16),
              if (dash.role == Role.manager || dash.role == Role.admin) ...[
                _SectionHeader(title: 'Team Management', action: 'View All'),
                const SizedBox(height: 8),
                _TeamSection(
                  name: 'Engineering Team',
                  members: '24 members',
                  isOpen: _engineeringOpen,
                  onToggle: () => setState(() => _engineeringOpen = !_engineeringOpen),
                  people: const [
                    _TeamPerson('Sarah Johnson', 'Team Lead'),
                    _TeamPerson('Michael Chen', 'Developer'),
                    _TeamPerson('Emily Rodriguez', 'Developer'),
                  ],
                ),
                const SizedBox(height: 8),
                _TeamSection(
                  name: 'Design Team',
                  members: '12 members',
                  isOpen: _designOpen,
                  onToggle: () => setState(() => _designOpen = !_designOpen),
                  people: const [
                    _TeamPerson('Salma Trabelsi', 'Team Lead'),
                    _TeamPerson('Fatma Zohra', 'Designer'),
                    _TeamPerson('Rim Khelifi', 'Designer'),
                  ],
                ),
              ],
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Failed to load dashboard: $e')),
    );
  }
}

class _TopBar extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onNotifications;

  const _TopBar({
    required this.title,
    required this.subtitle,
    required this.onNotifications,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: const Color(0xFF1F2A44),
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: const Text('A', style: TextStyle(color: Colors.white)),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            Container(
              margin: const EdgeInsets.only(top: 2),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(subtitle, style: const TextStyle(fontSize: 11)),
            ),
          ],
        ),
        const Spacer(),
        IconButton(
          onPressed: onNotifications,
          icon: const Icon(Icons.notifications_none),
        ),
      ],
    );
  }
}

class _StatGrid extends StatelessWidget {
  final List<_StatItem> items;
  const _StatGrid({required this.items});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.4,
      ),
      itemBuilder: (context, i) {
        final item = items[i];
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: item.color.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(item.icon, color: item.color, size: 18),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: item.color.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(item.delta, style: TextStyle(color: item.color, fontSize: 11)),
                    ),
                  ],
                ),
                const Spacer(),
                Text(item.value, style: Theme.of(context).textTheme.titleLarge),
                Text(item.label, style: const TextStyle(color: Color(0xFF6B7280))),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _StatItem {
  final String label;
  final String value;
  final IconData icon;
  final String delta;
  final Color color;

  _StatItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.delta,
    required this.color,
  });
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String action;
  const _SectionHeader({required this.title, required this.action});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        Text(action, style: TextStyle(color: Theme.of(context).colorScheme.primary)),
      ],
    );
  }
}

class _TeamSection extends StatelessWidget {
  final String name;
  final String members;
  final bool isOpen;
  final VoidCallback onToggle;
  final List<_TeamPerson> people;

  const _TeamSection({
    required this.name,
    required this.members,
    required this.isOpen,
    required this.onToggle,
    required this.people,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          ListTile(
            onTap: onToggle,
            leading: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.group, color: Theme.of(context).colorScheme.secondary),
            ),
            title: Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Text(members),
            trailing: Icon(isOpen ? Icons.expand_less : Icons.expand_more),
          ),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 200),
            firstChild: const SizedBox.shrink(),
            secondChild: Column(
              children: [
                for (final person in people)
                  ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.person)),
                    title: Text(person.name),
                    subtitle: Text(person.role),
                  ),
              ],
            ),
            crossFadeState: isOpen ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          ),
        ],
      ),
    );
  }
}

class _TeamPerson {
  final String name;
  final String role;
  const _TeamPerson(this.name, this.role);
}
