import json
from datetime import datetime
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from app import models, schemas
from app.auth import get_db, get_current_user
from app.core.permissions import require_task_access

router = APIRouter(prefix="/tasks", tags=["comments"])


@router.post(
    "/{task_id}/comments",
    response_model=schemas.CommentOut,
    summary="Add comment",
    description="Accepts: CommentCreate. Returns: CommentOut.",
)
def add_comment(
    task_id: int,
    payload: schemas.CommentCreate,
    db: Session = Depends(get_db),
    current: models.User = Depends(get_current_user),
):
    task = db.get(models.Task, task_id)
    if not task:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Task not found")
    require_task_access(current, task)
    comment = models.Comment(task_id=task_id, author_id=current.id, body=payload.body)
    db.add(comment)

    assignee_id = task.assignee_id
    if assignee_id != current.id:
        db.add(
            models.Notification(
                user_id=assignee_id,
                type=models.NotificationType.COMMENT_ADDED,
                payload=json.dumps({"task_id": task_id}),
                created_at=datetime.utcnow(),
            )
        )
    team_lead = (
        db.query(models.Team).filter(models.Team.id == task.assignee.team_id).first()
    )
    if team_lead and team_lead.lead_id and team_lead.lead_id != current.id:
        db.add(
            models.Notification(
                user_id=team_lead.lead_id,
                type=models.NotificationType.COMMENT_ADDED,
                payload=json.dumps({"task_id": task_id}),
                created_at=datetime.utcnow(),
            )
        )

    db.commit()
    db.refresh(comment)
    return comment


@router.get(
    "/{task_id}/comments",
    response_model=list[schemas.CommentOut],
    summary="List comments",
    description="Accepts: task_id path. Returns: CommentOut[].",
)
def list_comments(
    task_id: int,
    db: Session = Depends(get_db),
    current: models.User = Depends(get_current_user),
):
    task = db.get(models.Task, task_id)
    if not task:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Task not found")
    require_task_access(current, task)
    return db.query(models.Comment).filter(models.Comment.task_id == task_id).all()
