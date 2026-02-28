from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from app import models, schemas
from app.auth import get_db, get_current_user, require_roles

router = APIRouter(prefix="/users", tags=["users"])


@router.get(
    "",
    response_model=list[schemas.UserOut],
    summary="List users",
    description="Accepts: query role, team_id. Returns: UserOut[].",
)
def list_users(
    role: models.Role | None = None,
    team_id: int | None = None,
    db: Session = Depends(get_db),
    _user: models.User = Depends(require_roles(models.Role.ADMIN, models.Role.MANAGER)),
):
    query = db.query(models.User)
    if role:
        query = query.filter(models.User.role == role)
    if team_id is not None:
        query = query.filter(models.User.team_id == team_id)
    return query.all()


@router.get(
    "/me",
    response_model=schemas.UserOut,
    summary="Get current user",
    description="Accepts: none. Returns: UserOut.",
)
def me(current: models.User = Depends(get_current_user)):
    return current


@router.patch(
    "/{user_id}",
    response_model=schemas.UserOut,
    summary="Update user",
    description="Accepts: UserUpdate. Returns: UserOut.",
)
def update_user(
    user_id: int,
    payload: schemas.UserUpdate,
    db: Session = Depends(get_db),
    _admin: models.User = Depends(require_roles(models.Role.ADMIN)),
):
    user = db.get(models.User, user_id)
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    data = payload.model_dump(exclude_unset=True)
    for key, value in data.items():
        setattr(user, key, value)
    db.commit()
    db.refresh(user)
    return user
