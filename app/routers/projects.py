from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from app import models, schemas
from app.auth import get_db, get_current_user, require_roles
from app.core.permissions import require_project_access, ensure_user_in_team

router = APIRouter(prefix="/projects", tags=["projects"])


@router.post(
    "",
    response_model=schemas.ProjectOut,
    summary="Create project",
    description="Accepts: ProjectCreate. Returns: ProjectOut.",
)
def create_project(
    payload: schemas.ProjectCreate,
    db: Session = Depends(get_db),
    current: models.User = Depends(require_roles(models.Role.MANAGER, models.Role.LEAD)),
):
    ensure_user_in_team(current, payload.team_id)
    project = models.Project(
        name=payload.name,
        description=payload.description,
        owner_id=current.id,
        team_id=payload.team_id,
        start_date=payload.start_date,
        due_date=payload.due_date,
    )
    db.add(project)
    db.commit()
    db.refresh(project)
    return project


@router.get(
    "",
    response_model=list[schemas.ProjectOut],
    summary="List projects",
    description="Accepts: query team_id, status. Returns: ProjectOut[].",
)
def list_projects(
    team_id: int | None = None,
    status: models.ProjectStatus | None = None,
    db: Session = Depends(get_db),
    current: models.User = Depends(get_current_user),
):
    if current.role not in (models.Role.ADMIN, models.Role.MANAGER, models.Role.LEAD):
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Forbidden")
    query = db.query(models.Project)
    if current.role == models.Role.LEAD:
        query = query.filter(models.Project.team_id == current.team_id)
    if team_id is not None:
        query = query.filter(models.Project.team_id == team_id)
    if status is not None:
        query = query.filter(models.Project.status == status)
    return query.all()


@router.get(
    "/{project_id}",
    response_model=schemas.ProjectOut,
    summary="Get project",
    description="Accepts: project_id path. Returns: ProjectOut.",
)
def get_project(
    project_id: int,
    db: Session = Depends(get_db),
    current: models.User = Depends(get_current_user),
):
    project = db.get(models.Project, project_id)
    if not project:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Project not found")
    require_project_access(current, project)
    return project


@router.patch(
    "/{project_id}",
    response_model=schemas.ProjectOut,
    summary="Update project",
    description="Accepts: ProjectUpdate. Returns: ProjectOut.",
)
def update_project(
    project_id: int,
    payload: schemas.ProjectUpdate,
    db: Session = Depends(get_db),
    current: models.User = Depends(require_roles(models.Role.MANAGER, models.Role.LEAD)),
):
    project = db.get(models.Project, project_id)
    if not project:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Project not found")
    require_project_access(current, project)
    data = payload.model_dump(exclude_unset=True)
    for key, value in data.items():
        setattr(project, key, value)
    db.commit()
    db.refresh(project)
    return project
