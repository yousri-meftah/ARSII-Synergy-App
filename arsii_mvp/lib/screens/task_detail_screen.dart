import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:arsii_mvp/models/enums.dart';
import 'package:arsii_mvp/state/providers.dart';
import 'package:arsii_mvp/services/task_service.dart';

class TaskDetailScreen extends ConsumerStatefulWidget {
  final int taskId;
  const TaskDetailScreen({super.key, required this.taskId});

  @override
  ConsumerState<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends ConsumerState<TaskDetailScreen> {
  final _commentCtrl = TextEditingController();

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final asyncTask = ref.watch(taskDetailProvider(widget.taskId));
    final asyncComments = ref.watch(commentsProvider(widget.taskId));
    final service = ref.watch(taskServiceProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Task Detail')),
      body: asyncTask.when(
        data: (task) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1E2A5E), Color(0xFF00A5A5)],
                  ),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(color: Colors.white),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      task.description ?? 'No description',
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      const Icon(Icons.flag),
                      const SizedBox(width: 8),
                      const Text('Status'),
                      const Spacer(),
                      DropdownButton<TaskStatus>(
                        value: task.status,
                        underline: const SizedBox.shrink(),
                        items: TaskStatus.values
                            .map((s) => DropdownMenuItem(value: s, child: Text(s.name)))
                            .toList(),
                        onChanged: (s) async {
                          if (s == null) return;
                          await service.updateStatus(task.id, s);
                          ref.invalidate(taskDetailProvider(widget.taskId));
                          ref.invalidate(tasksProvider(const TaskFilter()));
                          ref.invalidate(dashboardProvider);
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text('Comments', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              asyncComments.when(
                data: (comments) => Column(
                  children: [
                    if (comments.isEmpty)
                      const Text('No comments'),
                    for (final c in comments)
                      ListTile(
                        title: Text(c.body),
                        subtitle: Text(c.createdAt),
                      ),
                  ],
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Text('Failed to load comments: $e'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _commentCtrl,
                decoration: const InputDecoration(labelText: 'Add a comment'),
                minLines: 1,
                maxLines: 3,
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () async {
                  if (_commentCtrl.text.trim().isEmpty) return;
                  await service.addComment(task.id, _commentCtrl.text.trim());
                  _commentCtrl.clear();
                  ref.invalidate(commentsProvider(widget.taskId));
                },
                child: const Text('Post Comment'),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Failed to load task: $e')),
      ),
    );
  }
}
