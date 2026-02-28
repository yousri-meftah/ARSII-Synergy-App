from datetime import date, datetime
import json
from fastapi import APIRouter, Depends, HTTPException, status, Request
from sqlalchemy.orm import Session
from sqlalchemy import or_
from app import models, schemas
from app.auth import get_db, get_current_user, require_roles
from app.core.permissions import require_task_access, ensure_user_in_team

router = APIRouter(prefix="/tasks", tags=["tasks"])


def _create_notification(db: Session, user_id: int, ntype: models.NotificationType, payload: dict) -> None:
    notification = models.Notification(
        user_id=user_id,
        type=ntype,
        payload=json.dumps(payload),
        created_at=datetime.utcnow(),
    )
    db.add(notification)


async def _emit_task_event(request: Request, event: str, task: models.Task) -> None:
    manager = request.app.state.ws_manager
    payload = {"event": event, "task": schemas.TaskOut.model_validate(task).model_dump()}
    await manager.broadcast(payload)


@router.post(
    "",
    response_model=schemas.TaskOut,
    summary="Create task",
    description="Accepts: TaskCreate. Returns: TaskOut.",
)
async def create_task(
    payload: schemas.TaskCreate,
    db: Session = Depends(get_db),
    current: models.User = Depends(require_roles(models.Role.MANAGER, models.Role.LEAD)),
    request: Request = None,
):
    project = db.get(models.Project, payload.project_id)
    if not project:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Project not found")
    ensure_user_in_team(current, project.team_id)
    assignee = db.get(models.User, payload.assignee_id)
    if not assignee:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Assignee not found")
    if current.role == models.Role.LEAD and assignee.team_id != current.team_id:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Assignee not in your team")
    task = models.Task(
        project_id=payload.project_id,
        title=payload.title,
        description=payload.description,
        assignee_id=payload.assignee_id,
        due_date=payload.due_date,
        created_by=current.id,
    )
    db.add(task)
    db.flush()
    _create_notification(db, assignee.id, models.NotificationType.TASK_ASSIGNED, {"task_id": task.id})
    db.commit()
    db.refresh(task)
    if request is not None:
        await _emit_task_event(request, "TASK_ASSIGNED", task)
    return task


@router.get(
    "",
    response_model=list[schemas.TaskOut],
    summary="List tasks",
    description="Accepts: query project_id, assignee_id, status, due_before, search. Returns: TaskOut[].",
)
def list_tasks(
    project_id: int | None = None,
    assignee_id: int | None = None,
    status: models.TaskStatus | None = None,
    due_before: date | None = None,
    search: str | None = None,
    db: Session = Depends(get_db),
    current: models.User = Depends(get_current_user),
):
    query = db.query(models.Task)
    if current.role == models.Role.USER:
        query = query.filter(models.Task.assignee_id == current.id)
    elif current.role == models.Role.LEAD:
        query = query.join(models.User, models.Task.assignee_id == models.User.id).filter(
            models.User.team_id == current.team_id
        )
    if project_id is not None:
        query = query.filter(models.Task.project_id == project_id)
    if assignee_id is not None:
        query = query.filter(models.Task.assignee_id == assignee_id)
    if status is not None:
        query = query.filter(models.Task.status == status)
    if due_before is not None:
        query = query.filter(models.Task.due_date <= due_before)
    if search:
        query = query.filter(or_(models.Task.title.ilike(f"%{search}%"), models.Task.description.ilike(f"%{search}%")))
    return query.all()


@router.get(
    "/{task_id}",
    response_model=schemas.TaskOut,
    summary="Get task",
    description="Accepts: task_id path. Returns: TaskOut.",
)
def get_task(
    task_id: int,
    db: Session = Depends(get_db),
    current: models.User = Depends(get_current_user),
):
    task = db.get(models.Task, task_id)
    if not task:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Task not found")
    require_task_access(current, task)
    return task


@router.patch(
    "/{task_id}",
    response_model=schemas.TaskOut,
    summary="Update task",
    description="Accepts: TaskUpdate. Returns: TaskOut.",
)
async def update_task(
    task_id: int,
    payload: schemas.TaskUpdate,
    db: Session = Depends(get_db),
    current: models.User = Depends(get_current_user),
    request: Request = None,
):
    task = db.get(models.Task, task_id)
    if not task:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Task not found")
    require_task_access(current, task)
    data = payload.model_dump(exclude_unset=True)
    prev_status = task.status
    prev_assignee = task.assignee_id
    for key, value in data.items():
        setattr(task, key, value)
    db.commit()
    db.refresh(task)
    if prev_assignee != task.assignee_id:
        _create_notification(db, task.assignee_id, models.NotificationType.TASK_ASSIGNED, {"task_id": task.id})
        db.commit()
    if request is not None:
        if prev_status != task.status:
            await _emit_task_event(request, "TASK_STATUS_CHANGED", task)
        else:
            await _emit_task_event(request, "TASK_UPDATED", task)
    return task


@router.post(
    "/{task_id}/status",
    response_model=schemas.TaskOut,
    summary="Update task status",
    description="Accepts: TaskStatusUpdate. Returns: TaskOut.",
)
async def update_task_status(
    task_id: int,
    payload: schemas.TaskStatusUpdate,
    db: Session = Depends(get_db),
    current: models.User = Depends(get_current_user),
    request: Request = None,
):
    task = db.get(models.Task, task_id)
    if not task:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Task not found")
    require_task_access(current, task)
    task.status = payload.status
    db.commit()
    db.refresh(task)
    if request is not None:
        await _emit_task_event(request, "TASK_STATUS_CHANGED", task)
    return task
