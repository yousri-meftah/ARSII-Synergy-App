from __future__ import annotations

from datetime import datetime, timedelta, date
from collections import Counter, defaultdict
from sqlalchemy.orm import Session
from app import models


def _visible_tasks(db: Session, user: models.User) -> list[models.Task]:
    query = db.query(models.Task)
    if user.role == models.Role.USER:
        return query.filter(models.Task.assignee_id == user.id).all()
    if user.role == models.Role.LEAD:
        return (
            query.join(models.User, models.Task.assignee_id == models.User.id)
            .filter(models.User.team_id == user.team_id)
            .all()
        )
    return query.all()


def _visible_projects(db: Session, user: models.User) -> list[models.Project]:
    query = db.query(models.Project)
    if user.role == models.Role.LEAD:
        return query.filter(models.Project.team_id == user.team_id).all()
    if user.role == models.Role.USER:
        task_project_ids = [
            row[0]
            for row in db.query(models.Task.project_id)
            .filter(models.Task.assignee_id == user.id)
            .distinct()
            .all()
        ]
        if not task_project_ids:
            return []
        return query.filter(models.Project.id.in_(task_project_ids)).all()
    return query.all()


def build_ai_context(db: Session, user: models.User) -> dict:
    today = date.today()
    tasks = _visible_tasks(db, user)
    projects = _visible_projects(db, user)
    user_ids = {task.assignee_id for task in tasks}

    users = []
    if user.role in (models.Role.ADMIN, models.Role.MANAGER):
        users = db.query(models.User).all()
    elif user.role == models.Role.LEAD and user.team_id is not None:
        users = db.query(models.User).filter(models.User.team_id == user.team_id).all()
    else:
        users = [user]

    recent_comments = (
        db.query(models.Comment)
        .join(models.Task, models.Comment.task_id == models.Task.id)
        .filter(models.Comment.created_at >= datetime.utcnow() - timedelta(days=7))
        .order_by(models.Comment.created_at.desc())
        .limit(20)
        .all()
    )

    if user.role == models.Role.USER:
        recent_comments = [comment for comment in recent_comments if comment.task.assignee_id == user.id]
    elif user.role == models.Role.LEAD:
        recent_comments = [
            comment for comment in recent_comments if comment.task.assignee.team_id == user.team_id
        ]

    workload = []
    member_profiles = []
    for candidate in users:
        open_tasks = sum(
            1 for task in tasks if task.assignee_id == candidate.id and task.status != models.TaskStatus.DONE
        )
        done_tasks = [
            task for task in tasks if task.assignee_id == candidate.id and task.status == models.TaskStatus.DONE
        ]
        skills = _top_keywords(done_tasks)
        availability = _availability_label(open_tasks)
        workload.append(
            {
                "user_id": candidate.id,
                "name": candidate.full_name,
                "role": candidate.role.value,
                "open_tasks": open_tasks,
                "availability": availability,
            }
        )
        member_profiles.append(
            {
                "user_id": candidate.id,
                "name": candidate.full_name,
                "role": candidate.role.value,
                "team_id": candidate.team_id,
                "team_name": candidate.team.name if candidate.team else None,
                "completed_tasks": len(done_tasks),
                "availability": availability,
                "best_at": skills,
            }
        )

    teams = _build_team_profiles(projects, tasks, users)
    project_states = {
        "active": len([project for project in projects if project.status == models.ProjectStatus.ACTIVE]),
        "completed": len([project for project in projects if project.status == models.ProjectStatus.COMPLETED]),
        "on_hold": len([project for project in projects if project.status == models.ProjectStatus.ON_HOLD]),
    }

    return {
        "scope": user.role.value,
        "generated_at": datetime.utcnow(),
        "today": today.isoformat(),
        "project_states": project_states,
        "projects": [
            {
                "id": project.id,
                "name": project.name,
                "status": project.status.value,
                "due_date": project.due_date.isoformat() if project.due_date else None,
                "team_id": project.team_id,
            }
            for project in projects
        ],
        "tasks": [
            {
                "id": task.id,
                "title": task.title,
                "project_id": task.project_id,
                "assignee_id": task.assignee_id,
                "status": task.status.value,
                "due_date": task.due_date.isoformat() if task.due_date else None,
                "is_overdue": bool(task.due_date and task.due_date < today and task.status != models.TaskStatus.DONE),
                "due_soon": bool(task.due_date and task.due_date <= today + timedelta(days=1) and task.status != models.TaskStatus.DONE),
            }
            for task in tasks
        ],
        "users": [
            {
                "id": candidate.id,
                "name": candidate.full_name,
                "role": candidate.role.value,
                "team_id": candidate.team_id,
            }
            for candidate in users
        ],
        "teams": teams,
        "member_profiles": member_profiles,
        "workload": workload,
        "recent_comments": [
            {
                "task_id": comment.task_id,
                "author_id": comment.author_id,
                "body": comment.body,
                "created_at": comment.created_at.isoformat(),
            }
            for comment in recent_comments
        ],
        "accessible_user_ids": sorted(user_ids),
    }


def _availability_label(open_tasks: int) -> str:
    if open_tasks <= 2:
        return "available"
    if open_tasks <= 4:
        return "busy"
    return "overloaded"


def _top_keywords(tasks: list[models.Task]) -> list[str]:
    counter: Counter[str] = Counter()
    for task in tasks:
        content = f"{task.title} {task.description or ''}".lower()
        for token in content.split():
            cleaned = "".join(char for char in token if char.isalnum())
            if len(cleaned) >= 4:
                counter[cleaned] += 1
    return [word for word, _ in counter.most_common(4)]


def _build_team_profiles(
    projects: list[models.Project],
    tasks: list[models.Task],
    users: list[models.User],
) -> list[dict]:
    users_by_team: dict[int, list[models.User]] = defaultdict(list)
    for user in users:
        if user.team_id is not None:
            users_by_team[user.team_id].append(user)

    profiles: list[dict] = []
    for team_id, members in users_by_team.items():
        member_ids = {member.id for member in members}
        team_projects = [project for project in projects if project.team_id == team_id]
        team_tasks = [task for task in tasks if task.assignee_id in member_ids]
        completed_tasks = [task for task in team_tasks if task.status == models.TaskStatus.DONE]
        specialties = _top_keywords(completed_tasks) or _top_keywords(team_tasks)
        available_members = []
        for member in members:
            open_tasks = sum(
                1 for task in team_tasks if task.assignee_id == member.id and task.status != models.TaskStatus.DONE
            )
            if _availability_label(open_tasks) == "available":
                available_members.append(member.full_name)

        profiles.append(
            {
                "team_id": team_id,
                "team_name": members[0].team.name if members and members[0].team else f"Team {team_id}",
                "specialties": specialties,
                "project_count": len(team_projects),
                "completed_tasks": len(completed_tasks),
                "available_members": available_members[:3],
            }
        )
    return profiles
