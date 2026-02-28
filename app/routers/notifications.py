from datetime import datetime
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from app import models, schemas
from app.auth import get_db, get_current_user

router = APIRouter(prefix="/notifications", tags=["notifications"])


@router.get(
    "",
    response_model=list[schemas.NotificationOut],
    summary="List notifications",
    description="Accepts: query unread. Returns: NotificationOut[].",
)
def list_notifications(
    unread: bool | None = None,
    db: Session = Depends(get_db),
    current: models.User = Depends(get_current_user),
):
    query = db.query(models.Notification).filter(models.Notification.user_id == current.id)
    if unread:
        query = query.filter(models.Notification.read_at.is_(None))
    return query.order_by(models.Notification.created_at.desc()).all()


@router.post(
    "/{notification_id}/read",
    response_model=schemas.NotificationOut,
    summary="Mark notification read",
    description="Accepts: notification_id path. Returns: NotificationOut.",
)
def mark_read(
    notification_id: int,
    db: Session = Depends(get_db),
    current: models.User = Depends(get_current_user),
):
    notification = db.get(models.Notification, notification_id)
    if not notification or notification.user_id != current.id:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Notification not found")
    notification.read_at = datetime.utcnow()
    db.commit()
    db.refresh(notification)
    return notification
