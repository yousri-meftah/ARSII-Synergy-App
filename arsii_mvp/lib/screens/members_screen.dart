import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:arsii_mvp/state/providers.dart';
import 'package:arsii_mvp/models/enums.dart';

class MembersScreen extends ConsumerStatefulWidget {
  const MembersScreen({super.key});

  @override
  ConsumerState<MembersScreen> createState() => _MembersScreenState();
}

class _MembersScreenState extends ConsumerState<MembersScreen> {
  String _query = '';
  Role? _role;

  @override
  Widget build(BuildContext context) {
    final asyncUsers = ref.watch(usersProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Members')),
      body: asyncUsers.when(
        data: (users) {
          final filtered = users.where((u) {
            final matchesQuery = _query.isEmpty ||
                u.fullName.toLowerCase().contains(_query.toLowerCase()) ||
                u.email.toLowerCase().contains(_query.toLowerCase());
            final matchesRole = _role == null || u.role == _role;
            return matchesQuery && matchesRole;
          }).toList();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('User Directory', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 8),
                      TextField(
                        decoration: const InputDecoration(
                          hintText: 'Search users...',
                          prefixIcon: Icon(Icons.search),
                        ),
                        onChanged: (v) => setState(() => _query = v),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _FilterChip(
                            label: 'All',
                            selected: _role == null,
                            onTap: () => setState(() => _role = null),
                          ),
                          for (final r in Role.values)
                            _FilterChip(
                              label: r.name,
                              selected: _role == r,
                              onTap: () => setState(() => _role = r),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              for (final u in filtered)
                Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.12),
                      child: Text(u.fullName.isNotEmpty ? u.fullName[0] : 'U'),
                    ),
                    title: Text(u.fullName, style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(u.email),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 6,
                          children: [
                            _Tag(label: u.role.name),
                            const _Tag(label: 'Active'),
                          ],
                        ),
                      ],
                    ),
                    trailing: const Icon(Icons.chevron_right),
                  ),
                ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Failed to load users: $e')),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF1F2A44) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFE7EBF3)),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : const Color(0xFF6B7280),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;
  const _Tag({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary.withOpacity(0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(label, style: const TextStyle(fontSize: 11)),
    );
  }
}
