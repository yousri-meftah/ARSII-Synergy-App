from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from app import models, schemas
from app.auth import create_access_token, get_db, verify_password, hash_password, require_roles

router = APIRouter(prefix="/auth", tags=["auth"])


@router.post(
    "/login",
    response_model=schemas.LoginResponse,
    summary="Login",
    description="Accepts: {email, password}. Returns: {access_token, token_type, user: UserOut}.",
)
def login(payload: schemas.LoginRequest, db: Session = Depends(get_db)):
    user = db.query(models.User).filter(models.User.email == payload.email).first()
    if not user or not verify_password(payload.password, user.password_hash):
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid credentials")
    token = create_access_token({"sub": str(user.id)})
    return {"access_token": token, "token_type": "bearer", "user": user}


@router.post(
    "/register",
    response_model=schemas.UserOut,
    summary="Register user (Admin only)",
    description="Accepts: UserCreate. Returns: UserOut.",
)
def register(
    payload: schemas.UserCreate,
    db: Session = Depends(get_db),
    _admin: models.User = Depends(require_roles(models.Role.ADMIN)),
):
    exists = db.query(models.User).filter(models.User.email == payload.email).first()
    if exists:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Email already exists")
    user = models.User(
        email=payload.email,
        password_hash=hash_password(payload.password),
        full_name=payload.full_name,
        role=models.Role(payload.role),
        team_id=payload.team_id,
    )
    db.add(user)
    db.commit()
    db.refresh(user)
    return user
