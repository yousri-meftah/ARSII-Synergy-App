import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:arsii_mvp/models/ai.dart';
import 'package:arsii_mvp/models/enums.dart';
import 'package:arsii_mvp/models/project.dart';
import 'package:arsii_mvp/state/auth_state.dart';
import 'package:arsii_mvp/state/providers.dart';
import 'package:arsii_mvp/widgets/task_list.dart';

class ProjectsScreen extends ConsumerWidget {
  const ProjectsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncProjects = ref.watch(projectsProvider);
    final role = ref.watch(authProvider).user?.role ?? Role.user;
    final canCreate = role == Role.admin || role == Role.manager || role == Role.lead;

    return asyncProjects.when(
      data: (projects) {
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _ProjectsHero(
              count: projects.length,
              canCreate: canCreate,
            ),
            const SizedBox(height: 14),
            if (canCreate) ...[
              _QuickCreateRail(),
              const SizedBox(height: 14),
            ],
            if (projects.isEmpty)
              const _EmptyProjects()
            else
              for (final project in projects) _ProjectCard(project: project),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Failed to load projects: $e')),
    );
  }
}

class _ProjectsHero extends StatelessWidget {
  final int count;
  final bool canCreate;

  const _ProjectsHero({
    required this.count,
    required this.canCreate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF182848), Color(0xFF3D7BEE)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.workspaces_outline, color: Colors.white),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '$count live',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            'Projects',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 6),
          const Text(
            'Launch work, inspect tasks, and let AI suggest the right team before you commit.',
            style: TextStyle(color: Colors.white70, height: 1.35),
          ),
          if (!canCreate) ...[
            const SizedBox(height: 14),
            const _HeroHint(
              icon: Icons.visibility_outlined,
              text: 'View-only mode for your assigned project scope',
            ),
          ],
        ],
      ),
    );
  }
}

class _QuickCreateRail extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        Expanded(
          child: _ActionTile(
            title: 'Manual',
            subtitle: 'Create a project directly',
            icon: Icons.add_circle_outline,
            accent: const Color(0xFF3D7BEE),
            onTap: () async {
              await showModalBottomSheet<void>(
                context: context,
                isScrollControlled: true,
                showDragHandle: true,
                builder: (_) => const _CreateProjectSheet(),
              );
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ActionTile(
            title: 'AI Plan',
            subtitle: 'Recommend team and tasks',
            icon: Icons.auto_awesome,
            accent: const Color(0xFF10B981),
            onTap: () async {
              await showModalBottomSheet<void>(
                context: context,
                isScrollControlled: true,
                showDragHandle: true,
                builder: (_) => const _AIPlannerSheet(),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ActionTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color accent;
  final VoidCallback onTap;

  const _ActionTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: accent.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: accent),
              ),
              const SizedBox(height: 12),
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 4),
              Text(subtitle, style: const TextStyle(color: Color(0xFF6B7280), height: 1.3)),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProjectCard extends StatelessWidget {
  final Project project;

  const _ProjectCard({required this.project});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ProjectDetailScreen(project: project),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: _statusColor(project.status).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(Icons.folder_copy_outlined, color: _statusColor(project.status)),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(project.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                        const SizedBox(height: 4),
                        Text(
                          project.description ?? 'No description',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Color(0xFF6B7280), height: 1.3),
                        ),
                      ],
                    ),
                  ),
                  _StatusPill(text: project.status.name, color: _statusColor(project.status)),
                ],
              ),
              const SizedBox(height: 14),
              _ProgressBar(value: _progressFromStatus(project.status.name), color: _statusColor(project.status)),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _MiniMetric(
                      label: 'Due',
                      value: project.dueDate ?? 'Open',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _MiniMetric(
                      label: 'Team',
                      value: project.teamId?.toString() ?? '-',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _MiniMetric(
                      label: 'Health',
                      value: _healthLabel(project.status),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProjectDetailScreen extends ConsumerWidget {
  final Project project;

  const ProjectDetailScreen({super.key, required this.project});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncTasks = ref.watch(tasksProvider(TaskFilter(projectId: project.id)));

    return Scaffold(
      appBar: AppBar(title: Text(project.name)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _statusColor(project.status),
                  _statusColor(project.status).withOpacity(0.75),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _StatusPill(text: project.status.name, color: Colors.white),
                const SizedBox(height: 12),
                Text(
                  project.name,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 6),
                Text(
                  project.description ?? 'No description',
                  style: const TextStyle(color: Colors.white70, height: 1.35),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(child: _DarkMetric(label: 'Due', value: project.dueDate ?? 'Open')),
                    const SizedBox(width: 10),
                    Expanded(child: _DarkMetric(label: 'Team', value: project.teamId?.toString() ?? '-')),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text('Task Flow', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          asyncTasks.when(
            data: (tasks) => TaskList(tasks: tasks),
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(),
              ),
            ),
            error: (e, _) => Text('Failed to load tasks: $e'),
          ),
        ],
      ),
    );
  }
}

class _CreateProjectSheet extends ConsumerStatefulWidget {
  const _CreateProjectSheet();

  @override
  ConsumerState<_CreateProjectSheet> createState() => _CreateProjectSheetState();
}

class _CreateProjectSheetState extends ConsumerState<_CreateProjectSheet> {
  final _name = TextEditingController();
  final _description = TextEditingController();
  final _teamId = TextEditingController();
  final _dueDate = TextEditingController(text: DateFormat('yyyy-MM-dd').format(DateTime.now().add(const Duration(days: 14))));
  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    _teamId.dispose();
    _dueDate.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_name.text.trim().isEmpty) return;
    setState(() => _saving = true);
    try {
      await ref.read(projectServiceProvider).create(
            name: _name.text.trim(),
            description: _description.text.trim(),
            teamId: int.tryParse(_teamId.text.trim()),
            dueDate: _dueDate.text.trim(),
          );
      ref.invalidate(projectsProvider);
      if (mounted) Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 8,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Create project', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            const Text('Simple project setup with direct owner control.'),
            const SizedBox(height: 16),
            TextField(controller: _name, decoration: const InputDecoration(labelText: 'Project name')),
            const SizedBox(height: 10),
            TextField(
              controller: _description,
              minLines: 2,
              maxLines: 4,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: TextField(controller: _teamId, decoration: const InputDecoration(labelText: 'Team ID'))),
                const SizedBox(width: 10),
                Expanded(child: TextField(controller: _dueDate, decoration: const InputDecoration(labelText: 'Due date'))),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saving ? null : _submit,
                child: _saving
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Create Project'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AIPlannerSheet extends ConsumerStatefulWidget {
  const _AIPlannerSheet();

  @override
  ConsumerState<_AIPlannerSheet> createState() => _AIPlannerSheetState();
}

class _AIPlannerSheetState extends ConsumerState<_AIPlannerSheet> {
  final _name = TextEditingController();
  final _description = TextEditingController();
  final _dueDate = TextEditingController(text: DateFormat('yyyy-MM-dd').format(DateTime.now().add(const Duration(days: 14))));
  AIProjectPlanResponse? _plan;
  final Set<int> _selectedPeople = {};
  final Map<int, int?> _taskAssignments = {};
  bool _loading = false;
  bool _creating = false;

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    _dueDate.dispose();
    super.dispose();
  }

  Future<void> _generate() async {
    if (_name.text.trim().isEmpty || _description.text.trim().isEmpty) return;
    setState(() {
      _loading = true;
      _plan = null;
    });
    try {
      final plan = await ref.read(aiServiceProvider).projectPlan(
            name: _name.text.trim(),
            description: _description.text.trim(),
            dueDate: _dueDate.text.trim(),
          );
      if (mounted) {
        setState(() {
          _plan = plan;
          _selectedPeople
            ..clear()
            ..addAll(plan.recommendedPeople.take(plan.suggestedTeamSize).map((person) => person.userId));
          _taskAssignments
            ..clear()
            ..addAll(_buildInitialAssignments(plan));
        });
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _createFromPlan() async {
    final plan = _plan;
    if (plan == null) return;
    final selectedPeople = plan.recommendedPeople.where((person) => _selectedPeople.contains(person.userId)).toList();
    if (selectedPeople.isEmpty) return;
    final teamId = _dominantTeamId(selectedPeople);
    setState(() => _creating = true);
    try {
      final project = await ref.read(projectServiceProvider).create(
            name: _name.text.trim(),
            description: _description.text.trim(),
            teamId: teamId,
            dueDate: _dueDate.text.trim(),
          );
      for (int index = 0; index < plan.tasks.length; index++) {
        final task = plan.tasks[index];
        final taskAssigneeId = _resolvedAssignmentFor(index, plan);
        if (taskAssigneeId == null) continue;
        await ref.read(taskServiceProvider).create(
              projectId: project.id,
              title: task.title,
              description: task.description,
              assigneeId: taskAssigneeId,
              dueDate: _dueDate.text.trim(),
            );
      }
      ref.invalidate(projectsProvider);
      ref.invalidate(dashboardProvider);
      if (mounted) Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _creating = false);
    }
  }

  int? _dominantTeamId(List<AIRecommendedMember> selectedPeople) {
    final counts = <int, int>{};
    for (final person in selectedPeople) {
      if (person.teamId == null) continue;
      counts.update(person.teamId!, (value) => value + 1, ifAbsent: () => 1);
    }
    if (counts.isEmpty) return null;
    final ordered = counts.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    return ordered.first.key;
  }

  void _togglePerson(int userId) {
    setState(() {
      if (_selectedPeople.contains(userId)) {
        _selectedPeople.remove(userId);
      } else {
        _selectedPeople.add(userId);
      }
      _normalizeAssignments();
    });
  }

  void _assignTask(int taskIndex, int? userId) {
    setState(() {
      _taskAssignments[taskIndex] = userId;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 8,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: ListView(
          shrinkWrap: true,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF102A43), Color(0xFF10B981)],
                ),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('AI Staffing Planner', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
                  SizedBox(height: 6),
                  Text(
                    'Describe the outcome. ARSII Bot will suggest the right people, estimate squad size, and draft the starter tasks.',
                    style: TextStyle(color: Colors.white70, height: 1.35),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            TextField(controller: _name, decoration: const InputDecoration(labelText: 'Project name')),
            const SizedBox(height: 10),
            TextField(
              controller: _description,
              minLines: 3,
              maxLines: 5,
              decoration: const InputDecoration(labelText: 'Project brief'),
            ),
            const SizedBox(height: 10),
            TextField(controller: _dueDate, decoration: const InputDecoration(labelText: 'Target due date')),
            const SizedBox(height: 14),
            ElevatedButton.icon(
              onPressed: _loading ? null : _generate,
              icon: const Icon(Icons.auto_awesome),
              label: _loading ? const Text('Generating...') : const Text('Generate AI Plan'),
            ),
            if (_loading) ...[
              const SizedBox(height: 18),
              const Center(child: CircularProgressIndicator()),
            ],
            if (_plan != null) ...[
              const SizedBox(height: 18),
              _PlanSummary(summary: _plan!.summary),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: Text('Suggested build', style: Theme.of(context).textTheme.titleMedium),
                  ),
                  _TinyBadge(text: '${_selectedPeople.length}/${_plan!.suggestedTeamSize} selected'),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _MiniMetric(label: 'Recommended squad', value: '${_plan!.suggestedTeamSize} people'),
                  _MiniMetric(label: 'Available selected', value: _availableSelectedCount(_plan!).toString()),
                  _MiniMetric(label: 'Starter tasks', value: _plan!.tasks.length.toString()),
                ],
              ),
              const SizedBox(height: 14),
              Text('Suggested roles', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              for (final roleSlot in _plan!.suggestedRoles)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _RoleSlotCard(roleSlot: roleSlot),
                ),
              const SizedBox(height: 14),
              Text('Recommended people', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              for (final person in _plan!.recommendedPeople)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _RecommendedPersonCard(
                    person: person,
                    selected: _selectedPeople.contains(person.userId),
                    onToggle: () => _togglePerson(person.userId),
                  ),
                ),
              const SizedBox(height: 14),
              Text('Starter flow', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              for (int i = 0; i < _plan!.tasks.length; i++)
                _TaskStepCard(
                  index: i + 1,
                  task: _plan!.tasks[i],
                  selectedPeople: _selectedPeopleForPlan(_plan!),
                  selectedAssigneeId: _resolvedAssignmentFor(i, _plan!),
                  onAssigneeChanged: (userId) => _assignTask(i, userId),
                ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _creating || _selectedPeople.isEmpty ? null : _createFromPlan,
                  icon: const Icon(Icons.check_circle_outline),
                  label: _creating ? const Text('Creating...') : const Text('Create Project From Selection'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  int _availableSelectedCount(AIProjectPlanResponse plan) {
    return plan.recommendedPeople
        .where((person) => _selectedPeople.contains(person.userId) && person.availability == 'available')
        .length;
  }

  List<AIRecommendedMember> _selectedPeopleForPlan(AIProjectPlanResponse plan) {
    return plan.recommendedPeople.where((person) => _selectedPeople.contains(person.userId)).toList();
  }

  Map<int, int?> _buildInitialAssignments(AIProjectPlanResponse plan) {
    final selectedPeople = _selectedPeopleForPlan(plan);
    final assignments = <int, int?>{};
    for (int index = 0; index < plan.tasks.length; index++) {
      final task = plan.tasks[index];
      if (task.recommendedAssigneeId != null && _selectedPeople.contains(task.recommendedAssigneeId)) {
        assignments[index] = task.recommendedAssigneeId;
      } else if (selectedPeople.isNotEmpty) {
        assignments[index] = selectedPeople[index % selectedPeople.length].userId;
      } else {
        assignments[index] = null;
      }
    }
    return assignments;
  }

  void _normalizeAssignments() {
    final plan = _plan;
    if (plan == null) return;
    final selectedPeople = _selectedPeopleForPlan(plan);
    for (int index = 0; index < plan.tasks.length; index++) {
      final currentAssignee = _taskAssignments[index];
      if (currentAssignee != null && _selectedPeople.contains(currentAssignee)) {
        continue;
      }
      _taskAssignments[index] = selectedPeople.isEmpty ? null : selectedPeople[index % selectedPeople.length].userId;
    }
  }

  int? _resolvedAssignmentFor(int taskIndex, AIProjectPlanResponse plan) {
    final current = _taskAssignments[taskIndex];
    if (current != null && _selectedPeople.contains(current)) {
      return current;
    }
    final selectedPeople = _selectedPeopleForPlan(plan);
    if (selectedPeople.isEmpty) {
      return null;
    }
    final fallback = selectedPeople[taskIndex % selectedPeople.length].userId;
    _taskAssignments[taskIndex] = fallback;
    return fallback;
  }
}

class _RecommendedPersonCard extends StatelessWidget {
  final AIRecommendedMember person;
  final bool selected;
  final VoidCallback onToggle;

  const _RecommendedPersonCard({
    required this.person,
    required this.selected,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final accent = selected ? const Color(0xFF10B981) : const Color(0xFF3D7BEE);
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: selected ? accent.withOpacity(0.45) : Colors.transparent),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: accent.withOpacity(0.14),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.person_outline, color: accent),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(person.fullName, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                      const SizedBox(height: 2),
                      Text(
                        [
                          if (person.teamName != null) person.teamName!,
                          if (person.role != null) person.role!,
                        ].join('  •  '),
                        style: const TextStyle(color: Color(0xFF6B7280), fontSize: 12),
                      ),
                    ],
                  ),
                ),
                TextButton.icon(
                  onPressed: onToggle,
                  icon: Icon(selected ? Icons.remove_circle_outline : Icons.add_circle_outline, size: 18),
                  label: Text(selected ? 'Remove' : 'Add'),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(person.reason, style: const TextStyle(color: Color(0xFF6B7280), height: 1.3)),
            const SizedBox(height: 10),
            _PercentageBar(percentage: person.matchPercentage ?? 0, accent: accent),
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                if (person.availability != null) _TinyBadge(text: person.availability!),
                if ((person.matchPercentage ?? 0) > 0) _TinyBadge(text: '${person.matchPercentage}% match'),
                if (person.teamName != null) _TinyBadge(text: person.teamName!),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RoleSlotCard extends StatelessWidget {
  final AIRecommendedRoleSlot roleSlot;

  const _RoleSlotCard({required this.roleSlot});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Color(0x12000000), blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFF102A43).withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.layers_outlined, color: Color(0xFF102A43)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(roleSlot.label, style: const TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(roleSlot.note, style: const TextStyle(color: Color(0xFF6B7280), height: 1.3)),
              ],
            ),
          ),
          _TinyBadge(text: 'x${roleSlot.count}'),
        ],
      ),
    );
  }
}

class _TaskStepCard extends StatelessWidget {
  final int index;
  final AIPlannedTask task;
  final List<AIRecommendedMember> selectedPeople;
  final int? selectedAssigneeId;
  final ValueChanged<int?> onAssigneeChanged;

  const _TaskStepCard({
    required this.index,
    required this.task,
    required this.selectedPeople,
    required this.selectedAssigneeId,
    required this.onAssigneeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Color(0x12000000), blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: const Color(0xFF3D7BEE).withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Text('$index', style: const TextStyle(fontWeight: FontWeight.w700)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(task.title, style: const TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(task.description, style: const TextStyle(color: Color(0xFF6B7280), height: 1.3)),
                const SizedBox(height: 10),
                if (selectedPeople.isNotEmpty) ...[
                  DropdownButtonFormField<int>(
                    initialValue: selectedAssigneeId,
                    decoration: const InputDecoration(
                      labelText: 'Assign to',
                      isDense: true,
                    ),
                    items: [
                      for (final person in selectedPeople)
                        DropdownMenuItem<int>(
                          value: person.userId,
                          child: Text(person.fullName),
                        ),
                    ],
                    onChanged: onAssigneeChanged,
                  ),
                ] else if (task.recommendedAssigneeName != null) ...[
                  const SizedBox(height: 8),
                  _TinyBadge(text: task.recommendedAssigneeName!),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PlanSummary extends StatelessWidget {
  final String summary;

  const _PlanSummary({required this.summary});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F7FF),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFF3D7BEE).withOpacity(0.14),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.lightbulb_outline, color: Color(0xFF3D7BEE)),
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(summary, style: const TextStyle(height: 1.35))),
        ],
      ),
    );
  }
}

class _MiniMetric extends StatelessWidget {
  final String label;
  final String value;

  const _MiniMetric({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FB),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280))),
          const SizedBox(height: 3),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _DarkMetric extends StatelessWidget {
  final String label;
  final String value;

  const _DarkMetric({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.14),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.white70)),
          const SizedBox(height: 3),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.white)),
        ],
      ),
    );
  }
}

class _MemberChip extends StatelessWidget {
  final String name;

  const _MemberChip({required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F7FF),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        name.split(' ').first,
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _TinyBadge extends StatelessWidget {
  final String text;

  const _TinyBadge({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFF1F2A44).withOpacity(0.10),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _ScoreBar extends StatelessWidget {
  final double score;

  const _ScoreBar({required this.score});

  @override
  Widget build(BuildContext context) {
    final normalized = (score / 10).clamp(0.1, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('Match', style: TextStyle(fontSize: 11, color: Color(0xFF6B7280))),
            const Spacer(),
            Text(score.toStringAsFixed(1), style: const TextStyle(fontWeight: FontWeight.w700)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            minHeight: 8,
            value: normalized,
            backgroundColor: const Color(0xFFE7EBF3),
            color: const Color(0xFF10B981),
          ),
        ),
      ],
    );
  }
}

class _PercentageBar extends StatelessWidget {
  final int percentage;
  final Color accent;

  const _PercentageBar({
    required this.percentage,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final value = (percentage / 100).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('Match', style: TextStyle(fontSize: 11, color: Color(0xFF6B7280))),
            const Spacer(),
            Text('$percentage%', style: const TextStyle(fontWeight: FontWeight.w700)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            minHeight: 8,
            value: value,
            backgroundColor: const Color(0xFFE7EBF3),
            color: accent,
          ),
        ),
      ],
    );
  }
}

class _HeroHint extends StatelessWidget {
  final IconData icon;
  final String text;

  const _HeroHint({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: 16),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: const TextStyle(color: Colors.white70))),
      ],
    );
  }
}

class _EmptyProjects extends StatelessWidget {
  const _EmptyProjects();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: const Color(0xFF3D7BEE).withOpacity(0.12),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(Icons.inbox_outlined, color: Color(0xFF3D7BEE)),
            ),
            const SizedBox(height: 14),
            Text('No projects yet', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 6),
            const Text(
              'Create one manually or let AI suggest the team and starter workflow.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF6B7280), height: 1.35),
            ),
          ],
        ),
      ),
    );
  }
}

double _progressFromStatus(String status) {
  switch (status.toUpperCase()) {
    case 'COMPLETED':
      return 1.0;
    case 'ON_HOLD':
      return 0.35;
    default:
      return 0.68;
  }
}

String _healthLabel(ProjectStatus status) {
  switch (status) {
    case ProjectStatus.completed:
      return 'Strong';
    case ProjectStatus.onHold:
      return 'Slow';
    case ProjectStatus.active:
      return 'Moving';
  }
}

Color _statusColor(ProjectStatus status) {
  switch (status) {
    case ProjectStatus.completed:
      return const Color(0xFF10B981);
    case ProjectStatus.onHold:
      return const Color(0xFFF59E0B);
    case ProjectStatus.active:
      return const Color(0xFF3D7BEE);
  }
}

class _StatusPill extends StatelessWidget {
  final String text;
  final Color color;

  const _StatusPill({
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final background = color == Colors.white ? Colors.white.withOpacity(0.18) : color.withOpacity(0.12);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: color == Colors.white ? Colors.white : color,
        ),
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final double value;
  final Color color;

  const _ProgressBar({
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: LinearProgressIndicator(
        minHeight: 7,
        value: value,
        backgroundColor: const Color(0xFFE7EBF3),
        color: color,
      ),
    );
  }
}
