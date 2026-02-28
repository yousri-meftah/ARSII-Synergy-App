from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from app import models, schemas
from app.auth import get_db, require_roles, get_current_user

router = APIRouter(prefix="/teams", tags=["teams"])


@router.post(
    "",
    response_model=schemas.TeamOut,
    summary="Create team",
    description="Accepts: TeamCreate. Returns: TeamOut.",
)
def create_team(
    payload: schemas.TeamCreate,
    db: Session = Depends(get_db),
    _admin: models.User = Depends(require_roles(models.Role.ADMIN)),
):
    team = models.Team(name=payload.name, lead_id=payload.lead_id)
    db.add(team)
    db.commit()
    db.refresh(team)
    return team


@router.get(
    "",
    response_model=list[schemas.TeamOut],
    summary="List teams",
    description="Accepts: none. Returns: TeamOut[].",
)
def list_teams(
    db: Session = Depends(get_db),
    _user: models.User = Depends(require_roles(models.Role.ADMIN, models.Role.MANAGER)),
):
    return db.query(models.Team).all()


@router.get(
    "/{team_id}",
    response_model=schemas.TeamOut,
    summary="Get team",
    description="Accepts: team_id path. Returns: TeamOut.",
)
def get_team(
    team_id: int,
    db: Session = Depends(get_db),
    current: models.User = Depends(get_current_user),
):
    team = db.get(models.Team, team_id)
    if not team:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Team not found")
    if current.role not in (models.Role.ADMIN, models.Role.MANAGER) and current.team_id != team_id:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Forbidden")
    return team


@router.patch(
    "/{team_id}",
    response_model=schemas.TeamOut,
    summary="Update team",
    description="Accepts: TeamUpdate. Returns: TeamOut.",
)
def update_team(
    team_id: int,
    payload: schemas.TeamUpdate,
    db: Session = Depends(get_db),
    _admin: models.User = Depends(require_roles(models.Role.ADMIN)),
):
    team = db.get(models.Team, team_id)
    if not team:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Team not found")
    data = payload.model_dump(exclude_unset=True)
    for key, value in data.items():
        setattr(team, key, value)
    db.commit()
    db.refresh(team)
    return team


@router.get(
    "/{team_id}/hierarchy",
    response_model=schemas.HierarchyOut,
    summary="Team hierarchy",
    description="Accepts: team_id path. Returns: {team: TeamOut, lead: UserOut|null, members: UserOut[]}.",
)
def team_hierarchy(
    team_id: int,
    db: Session = Depends(get_db),
    current: models.User = Depends(get_current_user),
):
    team = db.get(models.Team, team_id)
    if not team:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Team not found")
    if current.role not in (models.Role.ADMIN, models.Role.MANAGER) and current.team_id != team_id:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Forbidden")
    lead = db.get(models.User, team.lead_id) if team.lead_id else None
    members = db.query(models.User).filter(models.User.team_id == team_id).all()
    return {"team": team, "lead": lead, "members": members}
