from fastapi import HTTPException, status
from sqlalchemy.orm import Session
from app import models


def assert_team_lead_or_manager(user: models.User, team_id: int | None) -> None:
    if user.role in (models.Role.ADMIN, models.Role.MANAGER):
        return
    if user.role == models.Role.LEAD and user.team_id == team_id:
        return
    raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Forbidden")


def can_access_task(user: models.User, task: models.Task) -> bool:
    if user.role in (models.Role.ADMIN, models.Role.MANAGER):
        return True
    if user.role == models.Role.LEAD and user.team_id == task.assignee.team_id:
        return True
    if user.role == models.Role.USER and user.id == task.assignee_id:
        return True
    return False


def can_access_project(user: models.User, project: models.Project) -> bool:
    if user.role in (models.Role.ADMIN, models.Role.MANAGER):
        return True
    if user.role == models.Role.LEAD and user.team_id == project.team_id:
        return True
    return False


def require_task_access(user: models.User, task: models.Task) -> None:
    if not can_access_task(user, task):
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Forbidden")


def require_project_access(user: models.User, project: models.Project) -> None:
    if not can_access_project(user, project):
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Forbidden")


def ensure_user_in_team(user: models.User, target_team_id: int | None) -> None:
    if user.role in (models.Role.ADMIN, models.Role.MANAGER):
        return
    if user.role == models.Role.LEAD and user.team_id == target_team_id:
        return
    raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Forbidden")


def get_user_or_404(db: Session, user_id: int) -> models.User:
    user = db.get(models.User, user_id)
    if not user:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="User not found")
    return user
