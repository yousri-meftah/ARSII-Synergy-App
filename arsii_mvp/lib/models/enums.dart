enum Role { admin, manager, lead, user }

enum TaskStatus { todo, inProgress, done }

enum ProjectStatus { active, completed, onHold }

enum NotificationType { taskAssigned, taskDueSoon, taskOverdue, commentAdded }

Role roleFromString(String value) {
  switch (value) {
    case 'ADMIN':
      return Role.admin;
    case 'MANAGER':
      return Role.manager;
    case 'LEAD':
      return Role.lead;
    default:
      return Role.user;
  }
}

String roleToString(Role role) {
  switch (role) {
    case Role.admin:
      return 'ADMIN';
    case Role.manager:
      return 'MANAGER';
    case Role.lead:
      return 'LEAD';
    case Role.user:
      return 'USER';
  }
}

TaskStatus taskStatusFromString(String value) {
  switch (value) {
    case 'IN_PROGRESS':
      return TaskStatus.inProgress;
    case 'DONE':
      return TaskStatus.done;
    default:
      return TaskStatus.todo;
  }
}

String taskStatusToString(TaskStatus status) {
  switch (status) {
    case TaskStatus.inProgress:
      return 'IN_PROGRESS';
    case TaskStatus.done:
      return 'DONE';
    case TaskStatus.todo:
      return 'TODO';
  }
}

ProjectStatus projectStatusFromString(String value) {
  switch (value) {
    case 'COMPLETED':
      return ProjectStatus.completed;
    case 'ON_HOLD':
      return ProjectStatus.onHold;
    default:
      return ProjectStatus.active;
  }
}

String projectStatusToString(ProjectStatus status) {
  switch (status) {
    case ProjectStatus.completed:
      return 'COMPLETED';
    case ProjectStatus.onHold:
      return 'ON_HOLD';
    case ProjectStatus.active:
      return 'ACTIVE';
  }
}

NotificationType notificationTypeFromString(String value) {
  switch (value) {
    case 'TASK_DUE_SOON':
      return NotificationType.taskDueSoon;
    case 'TASK_OVERDUE':
      return NotificationType.taskOverdue;
    case 'COMMENT_ADDED':
      return NotificationType.commentAdded;
    default:
      return NotificationType.taskAssigned;
  }
}
