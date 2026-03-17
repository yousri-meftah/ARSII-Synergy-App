from __future__ import annotations

from collections import Counter


BLOCKER_WORDS = ("blocked", "blocker", "waiting", "unclear", "stuck", "delay")
CONFLICT_WORDS = ("conflict", "risk", "problem", "issue", "blocker", "blocked", "delay", "overload")
GREETING_WORDS = ("hello", "hi", "hey", "salam", "good morning", "good afternoon", "good evening")
HELP_WORDS = ("help", "what can you do", "how can you help", "capabilities", "what do you know")
STAFFING_WORDS = (
    "who",
    "best",
    "handle",
    "owner",
    "assign",
    "recommend",
    "event",
    "project",
    "available",
    "fallback",
    "team",
)


def build_conflicts(context: dict) -> list[dict]:
    conflicts: list[dict] = []

    for workload in context["workload"]:
        if workload["open_tasks"] >= 5:
            conflicts.append(
                {
                    "title": f"{workload['name']} is overloaded",
                    "detail": f"{workload['name']} has {workload['open_tasks']} open tasks. That is high for an MVP team workflow.",
                    "severity": "high" if workload["open_tasks"] >= 7 else "medium",
                    "recommendation": "Reassign one or two tasks or push due dates to reduce deadline collisions.",
                    "entity_type": "user",
                    "entity_id": workload["user_id"],
                }
            )

    urgent_by_user: dict[int, list[dict]] = {}
    for task in context["tasks"]:
        if task["status"] == "DONE":
            continue
        if task["is_overdue"] or task["due_soon"]:
            urgent_by_user.setdefault(task["assignee_id"], []).append(task)

    for assignee_id, tasks in urgent_by_user.items():
        if len(tasks) >= 3:
            conflicts.append(
                {
                    "title": "Multiple urgent tasks assigned to one user",
                    "detail": f"User {assignee_id} has {len(tasks)} urgent tasks at once.",
                    "severity": "high",
                    "recommendation": "Split urgent work across the team and review the true priority order.",
                    "entity_type": "user",
                    "entity_id": assignee_id,
                }
            )

    for comment in context["recent_comments"]:
        body = comment["body"].lower()
        if any(word in body for word in BLOCKER_WORDS):
            conflicts.append(
                {
                    "title": "Potential blocker detected in comments",
                    "detail": f"Task {comment['task_id']} contains blocker language in recent discussion.",
                    "severity": "medium",
                    "recommendation": "Lead or manager should review the thread and confirm the next action owner.",
                    "entity_type": "task",
                    "entity_id": comment["task_id"],
                }
            )

    seen: set[tuple[str | None, int | None, str]] = set()
    deduped: list[dict] = []
    for item in conflicts:
        key = (item["entity_type"], item["entity_id"], item["title"])
        if key in seen:
            continue
        seen.add(key)
        deduped.append(item)
    return deduped[:6]


def build_insights(context: dict, conflicts: list[dict]) -> list[dict]:
    insights: list[dict] = []
    overdue = [task for task in context["tasks"] if task["is_overdue"]]
    due_soon = [task for task in context["tasks"] if task["due_soon"]]

    if overdue:
        insights.append(
            {
                "title": "Overdue work needs intervention",
                "detail": f"There are {len(overdue)} overdue tasks in the current scope.",
                "priority": "high",
                "entity_type": "task",
                "entity_id": overdue[0]["id"],
            }
        )

    if due_soon:
        insights.append(
            {
                "title": "Deadlines are approaching fast",
                "detail": f"{len(due_soon)} tasks are due within the next day.",
                "priority": "medium",
                "entity_type": "task",
                "entity_id": due_soon[0]["id"],
            }
        )

    active_projects = [project for project in context["projects"] if project["status"] == "ACTIVE"]
    if active_projects:
        insights.append(
            {
                "title": "Active delivery footprint",
                "detail": f"{len(active_projects)} active projects are currently visible in this role scope.",
                "priority": "low",
                "entity_type": "project",
                "entity_id": active_projects[0]["id"],
            }
        )

    if conflicts:
        first = conflicts[0]
        insights.append(
            {
                "title": "AI detected a coordination risk",
                "detail": first["detail"],
                "priority": first["severity"],
                "entity_type": first["entity_type"],
                "entity_id": first["entity_id"],
            }
        )

    if not insights:
        insights.append(
            {
                "title": "Execution is stable",
                "detail": "No major deadline or workload risk is visible in the current scope.",
                "priority": "low",
                "entity_type": None,
                "entity_id": None,
            }
        )

    return insights[:5]


def fallback_summary(scope: str, insights: list[dict], conflicts: list[dict]) -> tuple[str, str]:
    if conflicts:
        return (
            f"{scope.title()} scope has {len(conflicts)} coordination risks and {len(insights)} notable insights.",
            "rules",
        )
    return (f"{scope.title()} scope is mostly stable with {len(insights)} AI observations.", "rules")


def build_chat_fallback_reply(prompt: str, context: dict) -> str:
    lowered = prompt.lower().strip()
    conflicts = build_conflicts(context)
    if _looks_like_greeting(lowered):
        return _greeting_reply(context)
    if _looks_like_help_request(lowered):
        return _help_reply()
    if _looks_like_conflict_question(lowered):
        return _conflict_reply(context, conflicts)
    if _looks_like_staffing_question(lowered):
        return _staffing_reply(prompt, context)
    return _general_reply(context, conflicts)


def _looks_like_greeting(prompt: str) -> bool:
    return prompt in GREETING_WORDS


def _looks_like_help_request(prompt: str) -> bool:
    return any(word in prompt for word in HELP_WORDS)


def _looks_like_conflict_question(prompt: str) -> bool:
    return any(word in prompt for word in CONFLICT_WORDS)


def _looks_like_staffing_question(prompt: str) -> bool:
    return any(word in prompt for word in STAFFING_WORDS)


def _conflict_reply(context: dict, conflicts: list[dict]) -> str:
    overdue = [task for task in context["tasks"] if task["is_overdue"]]
    due_soon = [task for task in context["tasks"] if task["due_soon"]]
    if conflicts:
        top = conflicts[0]
        lines = [
            "Conflict status: Yes.",
            f"Top issue: {top['title']}. {top['detail']}",
            f"Action: {top['recommendation']}",
        ]
        if len(conflicts) > 1:
            second = conflicts[1]
            lines.append(f"Next issue: {second['title']}. {second['detail']}")
        return " ".join(lines)

    if overdue or due_soon:
        lines = ["Conflict status: No critical conflict, but execution needs attention."]
        if overdue:
            lines.append(f"There are {len(overdue)} overdue tasks.")
        if due_soon:
            lines.append(f"There are {len(due_soon)} tasks due within 24 hours.")
        lines.append("Action: review priorities and confirm owners for the nearest deadlines.")
        return " ".join(lines)

    return (
        "Conflict status: No major conflict detected. "
        "Workload and deadlines look stable in the current scope."
    )


def _greeting_reply(context: dict) -> str:
    active_projects = context.get("project_states", {}).get("active", 0)
    return (
        f"Hello. I am ARSII Bot. I can help with {active_projects} active projects, conflicts, staffing, "
        "ownership suggestions, and delivery risk. Ask me what you need."
    )


def _help_reply() -> str:
    return (
        "I can check conflicts, summarize project status, find overloaded people, recommend who should handle a task or event, "
        "and suggest ownership based on availability and past work."
    )


def _staffing_reply(prompt: str, context: dict) -> str:
    ranked_members = _rank_members_for_prompt(prompt, context)
    ranked_teams = _rank_teams_for_prompt(prompt, context)
    best = ranked_members[0] if ranked_members else None
    fallback = next((item for item in ranked_members[1:] if item["availability"] != "overloaded"), None)
    best_team = ranked_teams[0] if ranked_teams else None

    if not best and not best_team:
        return (
            "I do not have a strong recommendation from the current workspace history. "
            "There is not enough completed work in scope to rank a clear owner."
        )

    lines: list[str] = []
    if best:
        specialties = ", ".join(best["best_at"][:3]) if best["best_at"] else "similar delivery work"
        best_team_suffix = f" from {best['team_name']}" if best.get("team_name") else ""
        lines.append(
            f"Best match: {best['name']}{best_team_suffix}. "
            f"Why: {best['completed_tasks']} completed tasks and strongest match on {specialties}. "
            f"Availability: {best['availability']}."
        )
    if fallback:
        fallback_skills = ", ".join(fallback["best_at"][:2]) if fallback["best_at"] else "similar work"
        fallback_team_suffix = f" from {fallback['team_name']}" if fallback.get("team_name") else ""
        lines.append(
            f"Fallback: {fallback['name']}{fallback_team_suffix} "
            f"because they are {fallback['availability']} and strong on {fallback_skills}."
        )
    if best_team:
        team_specialties = ", ".join(best_team["specialties"][:3]) if best_team["specialties"] else "related work"
        lines.append(
            f"Best team: {best_team['team_name']}. "
            f"They fit this brief through {team_specialties} and have {best_team['completed_tasks']} completed tasks in history."
        )
    return " ".join(lines)


def _general_reply(context: dict, conflicts: list[dict]) -> str:
    active = context.get("project_states", {}).get("active", 0)
    overdue = len([task for task in context["tasks"] if task["is_overdue"]])
    due_soon = len([task for task in context["tasks"] if task["due_soon"]])
    lines = [
        f"Current state: {active} active projects, {overdue} overdue tasks, and {due_soon} tasks due soon."
    ]
    if conflicts:
        lines.append(f"Top risk: {conflicts[0]['title']}. {conflicts[0]['detail']}")
    else:
        lines.append("No major coordination conflict is visible right now.")
    return " ".join(lines)


def _rank_members_for_prompt(prompt: str, context: dict) -> list[dict]:
    prompt_tokens = _tokens(prompt)
    needs_management = any(token in prompt_tokens for token in {"manager", "admin", "director", "oversight"})
    ranked: list[dict] = []
    for member in context.get("member_profiles", []):
        if not needs_management and member.get("role") in {"ADMIN", "MANAGER"}:
            continue
        score = member.get("completed_tasks", 0) * 3
        if member.get("availability") == "available":
            score += 6
        elif member.get("availability") == "busy":
            score += 2
        else:
            score -= 6
        score += _overlap_score(prompt_tokens, member.get("best_at", [])) * 5
        ranked.append({**member, "score": score})
    ranked.sort(
        key=lambda item: (
            item["score"],
            item.get("availability") == "available",
            item.get("completed_tasks", 0),
        ),
        reverse=True,
    )
    return ranked


def _rank_teams_for_prompt(prompt: str, context: dict) -> list[dict]:
    prompt_tokens = _tokens(prompt)
    ranked: list[dict] = []
    for team in context.get("teams", []):
        score = team.get("completed_tasks", 0) * 2 + len(team.get("available_members", [])) * 3
        score += _overlap_score(prompt_tokens, team.get("specialties", [])) * 5
        ranked.append({**team, "score": score})
    ranked.sort(key=lambda item: item["score"], reverse=True)
    return ranked


def _tokens(text: str) -> set[str]:
    words: list[str] = []
    for token in text.lower().split():
        cleaned = "".join(char for char in token if char.isalnum())
        if len(cleaned) >= 3:
            words.append(cleaned)
    return set(words)


def _overlap_score(prompt_tokens: set[str], labels: list[str]) -> int:
    label_counter = Counter(labels)
    return sum(label_counter[label] for label in prompt_tokens if label in label_counter)
