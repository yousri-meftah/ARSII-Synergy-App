from datetime import date, timedelta
from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from sqlalchemy import func
from app import models, schemas
from app.auth import get_db, get_current_user

router = APIRouter(prefix="/dashboard", tags=["dashboard"])


def _task_counts(tasks):
    total = len(tasks)
    today = date.today()
    overdue = len([t for t in tasks if t.due_date and t.due_date < today and t.status != models.TaskStatus.DONE])
    due_soon = len([t for t in tasks if t.due_date and t.due_date <= today + timedelta(days=1) and t.status != models.TaskStatus.DONE])
    return total, overdue, due_soon


@router.get(
    "",
    response_model=schemas.DashboardUser | schemas.DashboardLead | schemas.DashboardManager | schemas.DashboardAdmin,
    summary="Dashboard",
    description="Accepts: none. Returns: DashboardOut (role-specific).",
)
def get_dashboard(
    db: Session = Depends(get_db),
    current: models.User = Depends(get_current_user),
):
    if current.role == models.Role.USER:
        tasks = db.query(models.Task).filter(models.Task.assignee_id == current.id).all()
        total, overdue, due_soon = _task_counts(tasks)
        return schemas.DashboardUser(
            role=current.role,
            total_tasks=total,
            overdue_tasks=overdue,
            due_soon_tasks=due_soon,
            my_tasks=tasks,
        )

    if current.role == models.Role.LEAD:
        tasks = (
            db.query(models.Task)
            .join(models.User, models.Task.assignee_id == models.User.id)
            .filter(models.User.team_id == current.team_id)
            .all()
        )
        total, overdue, due_soon = _task_counts(tasks)
        workload = (
            db.query(models.User, func.count(models.Task.id))
            .outerjoin(models.Task, (models.Task.assignee_id == models.User.id) & (models.Task.status != models.TaskStatus.DONE))
            .filter(models.User.team_id == current.team_id)
            .group_by(models.User.id)
            .all()
        )
        workload_items = [
            schemas.WorkloadItem(user=u, open_tasks=count) for u, count in workload
        ]
        return schemas.DashboardLead(
            role=current.role,
            total_tasks=total,
            overdue_tasks=overdue,
            due_soon_tasks=due_soon,
            team_tasks=tasks,
            workload=workload_items,
        )

    if current.role in (models.Role.MANAGER, models.Role.ADMIN):
        tasks = db.query(models.Task).all()
        total, overdue, due_soon = _task_counts(tasks)
        projects_summary = dict(
            db.query(models.Project.status, func.count(models.Project.id)).group_by(models.Project.status).all()
        )
        team_summary = dict(
            db.query(models.Team.name, func.count(models.User.id))
            .outerjoin(models.User, models.User.team_id == models.Team.id)
            .group_by(models.Team.name)
            .all()
        )
        if current.role == models.Role.ADMIN:
            return schemas.DashboardAdmin(
                role=current.role,
                total_tasks=total,
                overdue_tasks=overdue,
                due_soon_tasks=due_soon,
                projects_summary=projects_summary,
                team_summary=team_summary,
                user_count=db.query(models.User).count(),
                team_count=db.query(models.Team).count(),
            )
        return schemas.DashboardManager(
            role=current.role,
            total_tasks=total,
            overdue_tasks=overdue,
            due_soon_tasks=due_soon,
            projects_summary=projects_summary,
            team_summary=team_summary,
        )

    return {"detail": "Unsupported role"}
