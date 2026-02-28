import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:arsii_mvp/state/providers.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncNotifs = ref.watch(notificationsProvider);
    final service = ref.watch(notificationServiceProvider);

    return asyncNotifs.when(
      data: (items) {
        if (items.isEmpty) {
          return const Center(child: Text('No notifications'));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: items.length,
          itemBuilder: (context, i) {
            final n = items[i];
            return Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.secondary.withOpacity(0.12),
                  child: Icon(Icons.notifications, color: Theme.of(context).colorScheme.secondary),
                ),
                title: Text(n.type.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text(n.payload),
                trailing: n.readAt == null
                    ? TextButton(
                        onPressed: () async {
                          await service.markRead(n.id);
                          ref.invalidate(notificationsProvider);
                        },
                        child: const Text('Mark read'),
                      )
                    : const Text('Read'),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Failed to load notifications: $e')),
    );
  }
}
