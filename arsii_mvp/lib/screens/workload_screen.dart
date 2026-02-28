import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:arsii_mvp/state/providers.dart';

class WorkloadScreen extends ConsumerWidget {
  const WorkloadScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncWorkload = ref.watch(workloadProvider);

    return asyncWorkload.when(
      data: (items) {
        if (items.isEmpty) {
          return const Center(child: Text('No workload data'));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: items.length,
          itemBuilder: (context, i) {
            final item = items[i];
            return Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.secondary.withOpacity(0.15),
                  child: const Icon(Icons.person),
                ),
                title: Text(item.user.fullName, style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text(item.user.email),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text('${item.openTasks} open',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      )),
                ),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Failed to load workload: $e')),
    );
  }
}
