import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:arsii_mvp/models/enums.dart';
import 'package:arsii_mvp/state/providers.dart';
import 'package:arsii_mvp/widgets/task_list.dart';

enum TaskScope { mine, team, all }

class TasksScreen extends ConsumerStatefulWidget {
  final TaskScope scope;
  const TasksScreen({super.key, required this.scope});

  @override
  ConsumerState<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends ConsumerState<TasksScreen> {
  TaskStatus? _status;
  String _search = '';

  @override
  Widget build(BuildContext context) {
    final filter = TaskFilter(status: _status, search: _search);
    final asyncTasks = ref.watch(tasksProvider(filter));

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration(
                        hintText: 'Search tasks...',
                        prefixIcon: Icon(Icons.search),
                      ),
                      onChanged: (v) => setState(() => _search = v),
                    ),
                  ),
                  const SizedBox(width: 12),
                  DropdownButton<TaskStatus?>(
                    value: _status,
                    hint: const Text('Status'),
                    underline: const SizedBox.shrink(),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('All')),
                      ...TaskStatus.values.map(
                        (s) => DropdownMenuItem(value: s, child: Text(s.name)),
                      ),
                    ],
                    onChanged: (v) => setState(() => _status = v),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: asyncTasks.when(
              data: (tasks) => SingleChildScrollView(
                child: TaskList(tasks: tasks),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Failed to load tasks: $e')),
            ),
          ),
        ],
      ),
    );
  }
}
