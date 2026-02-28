import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:arsii_mvp/state/providers.dart';
import 'package:arsii_mvp/screens/members_screen.dart';

class TeamsScreen extends ConsumerWidget {
  const TeamsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncTeams = ref.watch(teamsProvider);

    return asyncTeams.when(
      data: (teams) {
        if (teams.isEmpty) {
          return const Center(child: Text('No teams'));
        }
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Teams', style: Theme.of(context).textTheme.titleMedium),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const MembersScreen()),
                    );
                  },
                  child: const Text('Members'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            for (final t in teams)
              Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.12),
                    child: Icon(Icons.group, color: Theme.of(context).colorScheme.primary),
                  ),
                  title: Text(t.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Wrap(
                    spacing: 8,
                    children: [
                      _Badge(text: 'Lead: ${t.leadId ?? 'Unassigned'}'),
                      const _Badge(text: 'Active'),
                    ],
                  ),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => TeamHierarchyScreen(teamId: t.id),
                      ),
                    );
                  },
                ),
              ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Failed to load teams: $e')),
    );
  }
}

class _Badge extends StatelessWidget {
  final String text;
  const _Badge({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 6),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary.withOpacity(0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(text, style: const TextStyle(fontSize: 11)),
    );
  }
}

class TeamHierarchyScreen extends ConsumerWidget {
  final int teamId;
  const TeamHierarchyScreen({super.key, required this.teamId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncHierarchy = ref.watch(teamHierarchyProvider(teamId));
    return Scaffold(
      appBar: AppBar(title: const Text('Team Hierarchy')),
      body: asyncHierarchy.when(
        data: (h) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(h.team.name, style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 6),
                    Text('Lead: ${h.lead?.fullName ?? 'Unassigned'}'),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              const SizedBox(height: 16),
              Text('Members', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              for (final m in h.members)
                ListTile(
                  title: Text(m.fullName),
                  subtitle: Text(m.email),
                ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Failed to load hierarchy: $e')),
      ),
    );
  }
}
