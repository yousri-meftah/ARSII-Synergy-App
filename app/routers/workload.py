from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from sqlalchemy import func
from app import models, schemas
from app.auth import get_db, require_roles

router = APIRouter(prefix="/workload", tags=["workload"])


@router.get(
    "",
    response_model=list[schemas.WorkloadItem],
    summary="Workload view",
    description="Accepts: none. Returns: WorkloadItem[].",
)
def workload(
    db: Session = Depends(get_db),
    current: models.User = Depends(require_roles(models.Role.MANAGER, models.Role.LEAD)),
):
    query = (
        db.query(models.User, func.count(models.Task.id))
        .outerjoin(models.Task, (models.Task.assignee_id == models.User.id) & (models.Task.status != models.TaskStatus.DONE))
    )
    if current.role == models.Role.LEAD:
        query = query.filter(models.User.team_id == current.team_id)
    query = query.group_by(models.User.id)
    return [schemas.WorkloadItem(user=u, open_tasks=count) for u, count in query.all()]
