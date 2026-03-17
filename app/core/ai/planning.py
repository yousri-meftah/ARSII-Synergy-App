from __future__ import annotations

import re
from collections import defaultdict
from sqlalchemy.orm import Session
from app import models


def _tokens(text: str) -> set[str]:
    return set(re.findall(r"[a-zA-Z0-9]+", text.lower()))


def _member_reason(user: models.User, completed_count: int, overlap_score: int) -> str:
    if overlap_score > 0:
        return f"{user.full_name} worked on similar delivery keywords before and closed {completed_count} completed tasks."
    return f"{user.full_name} has {completed_count} completed tasks in this team history."


def recommend_team_plan(db: Session, brief_name: str, brief_description: str) -> tuple[list[dict], list[dict], list[dict], int, list[dict]]:
    brief_tokens = _tokens(f"{brief_name} {brief_description}")
    teams = db.query(models.Team).all()
    projects = db.query(models.Project).all()
    tasks = db.query(models.Task).all()
    users = db.query(models.User).all()

    users_by_team = defaultdict(list)
    for user in users:
        if user.team_id is not None:
            users_by_team[user.team_id].append(user)

    team_scores: list[dict] = []
    for team in teams:
        team_projects = [project for project in projects if project.team_id == team.id]
        team_users = users_by_team.get(team.id, [])
        team_user_ids = {user.id for user in team_users}
        team_tasks = [task for task in tasks if task.assignee_id in team_user_ids]
        completed_tasks = [task for task in team_tasks if task.status == models.TaskStatus.DONE]
        specialties = _top_keywords(completed_tasks) or _top_keywords(team_tasks)

        project_overlap = 0
        for project in team_projects:
            project_overlap += len(
                brief_tokens & _tokens(f"{project.name} {project.description or ''}")
            )

        task_overlap = 0
        for task in completed_tasks:
            task_overlap += len(brief_tokens & _tokens(f"{task.title} {task.description or ''}"))

        score = float(project_overlap * 2 + task_overlap + len(completed_tasks) * 0.25)
        team_scores.append(
            {
                "team": team,
                "score": score,
                "completed_count": len(completed_tasks),
                "project_overlap": project_overlap,
                "task_overlap": task_overlap,
                "specialties": specialties,
            }
        )

    ranked = sorted(team_scores, key=lambda item: item["score"], reverse=True)
    if not ranked:
        return [], [], [], 0, []

    recommended_teams: list[dict] = []
    ranked_people: list[dict] = []
    for entry in ranked[:2]:
        team = entry["team"]
        team_users = users_by_team.get(team.id, [])
        member_entries = []
        for user in team_users:
            if user.role not in (models.Role.LEAD, models.Role.USER):
                continue
            completed_count = sum(
                1 for task in tasks if task.assignee_id == user.id and task.status == models.TaskStatus.DONE
            )
            overlap_score = sum(
                len(brief_tokens & _tokens(f"{task.title} {task.description or ''}"))
                for task in tasks
                if task.assignee_id == user.id
            )
            member_entries.append(
                {
                    "user_id": user.id,
                    "full_name": user.full_name,
                    "team_id": user.team_id,
                    "team_name": team.name,
                    "role": user.role.value,
                    "availability": _availability(user, tasks),
                    "reason": _member_reason(user, completed_count, overlap_score),
                    "score": completed_count + overlap_score,
                }
            )

        member_entries.sort(key=lambda item: item["score"], reverse=True)
        ranked_people.extend(member_entries)
        recommended_teams.append(
            {
                "team_id": team.id,
                "team_name": team.name,
                "score": round(entry["score"], 2),
                "reason": (
                    f"{team.name} matches the brief through similar projects/tasks and has "
                    f"{entry['completed_count']} completed tasks in its history."
                ),
                "specialties": entry["specialties"][:3],
                "members": [
                    {
                        "user_id": member["user_id"],
                        "full_name": member["full_name"],
                        "team_id": member["team_id"],
                        "team_name": member["team_name"],
                        "role": member["role"],
                        "availability": member["availability"],
                        "match_percentage": 0,
                        "reason": member["reason"],
                    }
                    for member in member_entries[:3]
                ],
            }
        )

    deduped_people: dict[int, dict] = {}
    max_score = max((person["score"] for person in ranked_people), default=1)
    for person in sorted(ranked_people, key=lambda item: item["score"], reverse=True):
        if person["user_id"] in deduped_people:
            continue
        percentage = max(35, min(98, int((person["score"] / max_score) * 100))) if max_score > 0 else 40
        deduped_people[person["user_id"]] = {
            **person,
            "match_percentage": percentage,
        }

    recommended_people = list(deduped_people.values())[:8]
    suggested_team_size = _suggested_team_size(brief_tokens, brief_description)
    suggested_roles = _suggested_roles(brief_tokens, brief_description, suggested_team_size)
    generated_tasks = _build_task_templates(brief_name, brief_description, recommended_people[: max(1, min(4, suggested_team_size))])
    return recommended_teams, generated_tasks, recommended_people, suggested_team_size, suggested_roles


def _build_task_templates(name: str, description: str, members: list[dict]) -> list[dict]:
    assignee = lambda index: members[index % len(members)] if members else None
    return [
        {
            "title": f"Scope and discovery for {name}",
            "description": f"Clarify requirements, risks, and success metrics. {description}",
            "recommended_assignee_id": assignee(0)["user_id"] if members else None,
            "recommended_assignee_name": assignee(0)["full_name"] if members else None,
        },
        {
            "title": f"Delivery plan for {name}",
            "description": "Break the work into milestones, dependencies, and execution phases.",
            "recommended_assignee_id": assignee(1)["user_id"] if len(members) > 1 else assignee(0)["user_id"] if members else None,
            "recommended_assignee_name": assignee(1)["full_name"] if len(members) > 1 else assignee(0)["full_name"] if members else None,
        },
        {
            "title": f"Implementation core for {name}",
            "description": "Build the core workflow and validate the main happy path.",
            "recommended_assignee_id": assignee(2)["user_id"] if len(members) > 2 else assignee(0)["user_id"] if members else None,
            "recommended_assignee_name": assignee(2)["full_name"] if len(members) > 2 else assignee(0)["full_name"] if members else None,
        },
        {
            "title": f"QA and release readiness for {name}",
            "description": "Test the full flow, resolve blockers, and prepare rollout notes.",
            "recommended_assignee_id": assignee(0)["user_id"] if members else None,
            "recommended_assignee_name": assignee(0)["full_name"] if members else None,
        },
    ]


def _availability(user: models.User, tasks: list[models.Task]) -> str:
    open_tasks = sum(1 for task in tasks if task.assignee_id == user.id and task.status != models.TaskStatus.DONE)
    if open_tasks <= 2:
        return "available"
    if open_tasks <= 4:
        return "busy"
    return "overloaded"


def _suggested_team_size(brief_tokens: set[str], brief_description: str) -> int:
    size = 3
    if len(brief_tokens) >= 8:
        size += 1
    if any(token in brief_tokens for token in {"event", "launch", "forum", "summit", "campaign", "partner"}):
        size += 1
    if len(brief_description.split()) >= 20:
        size += 1
    return min(max(size, 3), 6)


def _suggested_roles(brief_tokens: set[str], brief_description: str, team_size: int) -> list[dict]:
    combined = set(brief_tokens) | _tokens(brief_description)
    roles: list[dict] = [{"label": "Project owner", "count": 1, "note": "Keeps scope, timing, and approvals aligned."}]
    if any(token in combined for token in {"event", "summit", "forum", "venue", "speaker", "agenda", "organization"}):
        roles.append({"label": "Event organizer", "count": 1, "note": "Handles logistics, agenda, and onsite flow."})
    if any(token in combined for token in {"communication", "media", "press", "announcement", "community"}):
        roles.append({"label": "Communication lead", "count": 1, "note": "Owns messaging, outreach, and updates."})
    if any(token in combined for token in {"partner", "sponsor", "outreach", "relation", "external"}):
        roles.append({"label": "Outreach coordinator", "count": 1, "note": "Manages partners, sponsors, and external contacts."})
    if any(token in combined for token in {"marketing", "campaign", "social", "audience", "promotion"}):
        roles.append({"label": "Marketing support", "count": 1, "note": "Covers promotion, launch cadence, and engagement."})
    if len(roles) < team_size:
        roles.append({"label": "Execution support", "count": team_size - len(roles), "note": "Takes follow-up tasks and delivery support."})
    return roles[:team_size]


def _top_keywords(tasks: list[models.Task]) -> list[str]:
    bucket: dict[str, int] = {}
    for task in tasks:
        content = f"{task.title} {task.description or ''}".lower()
        for raw in re.findall(r"[a-zA-Z0-9]+", content):
            if len(raw) < 4:
                continue
            bucket[raw] = bucket.get(raw, 0) + 1
    return [word for word, _ in sorted(bucket.items(), key=lambda item: item[1], reverse=True)[:5]]
