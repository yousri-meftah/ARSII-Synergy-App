import 'package:flutter/material.dart';
import 'package:arsii_mvp/models/task.dart';
import 'package:arsii_mvp/models/enums.dart';
import 'package:arsii_mvp/screens/task_detail_screen.dart';

class TaskList extends StatelessWidget {
  final List<Task> tasks;
  const TaskList({super.key, required this.tasks});

  @override
  Widget build(BuildContext context) {
    if (tasks.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: Text('No tasks found')),
      );
    }
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: tasks.length,
      separatorBuilder: (_, __) => const SizedBox(height: 6),
      itemBuilder: (context, index) {
        final task = tasks[index];
        return Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _statusColor(task.status).withOpacity(0.15),
              child: Icon(Icons.check_circle, color: _statusColor(task.status)),
            ),
            title: Text(task.title, style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Text(task.description ?? 'No description'),
            trailing: _StatusChip(status: task.status),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => TaskDetailScreen(taskId: task.id),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _StatusChip extends StatelessWidget {
  final TaskStatus status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.name.toUpperCase(),
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600),
      ),
    );
  }
}

Color _statusColor(TaskStatus status) {
  switch (status) {
    case TaskStatus.inProgress:
      return const Color(0xFF00A5A5);
    case TaskStatus.done:
      return const Color(0xFF2E7D32);
    case TaskStatus.todo:
    default:
      return const Color(0xFFF4A259);
  }
}
