import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:arsii_mvp/state/providers.dart';

class ProjectsScreen extends ConsumerWidget {
  const ProjectsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncProjects = ref.watch(projectsProvider);

    return asyncProjects.when(
      data: (projects) {
        if (projects.isEmpty) {
          return const Center(child: Text('No projects'));
        }
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _HeaderCard(
              title: 'Project Activity',
              subtitle: 'Track progress, tasks, and deadlines.',
              count: projects.length,
            ),
            const SizedBox(height: 12),
            for (final p in projects)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.12),
                            child: Icon(Icons.folder, color: Theme.of(context).colorScheme.primary),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(p.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                          ),
                          _StatusPill(text: p.status.name),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(p.description ?? 'No description'),
                      const SizedBox(height: 10),
                      _ProgressBar(value: _progressFromStatus(p.status.name)),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          _InfoChip(label: 'Owner', value: 'Manager'),
                          const SizedBox(width: 8),
                          if (p.dueDate != null) _InfoChip(label: 'Due', value: p.dueDate!),
                          const SizedBox(width: 8),
                          _InfoChip(label: 'Team', value: p.teamId?.toString() ?? '-'),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: const [
                          _AvatarDot('A'),
                          _AvatarDot('S'),
                          _AvatarDot('K'),
                          _AvatarDot('+3'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Failed to load projects: $e')),
    );
  }
}

double _progressFromStatus(String status) {
  switch (status.toUpperCase()) {
    case 'COMPLETED':
      return 1.0;
    case 'ON_HOLD':
      return 0.3;
    default:
      return 0.6;
  }
}

class _HeaderCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final int count;
  const _HeaderCard({required this.title, required this.subtitle, required this.count});

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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white)),
                const SizedBox(height: 6),
                Text(subtitle, style: const TextStyle(color: Colors.white70)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text('$count', style: const TextStyle(color: Colors.white, fontSize: 18)),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final String value;
  const _InfoChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        '$label: $value',
        style: const TextStyle(fontSize: 11),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String text;
  const _StatusPill({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(text.toUpperCase(), style: const TextStyle(fontSize: 11)),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final double value;
  const _ProgressBar({required this.value});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: LinearProgressIndicator(
        minHeight: 6,
        value: value,
        backgroundColor: const Color(0xFFE7EBF3),
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}

class _AvatarDot extends StatelessWidget {
  final String label;
  const _AvatarDot(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 6),
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.center,
      child: Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }
}
