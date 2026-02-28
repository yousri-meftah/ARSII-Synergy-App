from datetime import date, datetime
from enum import Enum
from pydantic import BaseModel


class Role(str, Enum):
    ADMIN = "ADMIN"
    MANAGER = "MANAGER"
    LEAD = "LEAD"
    USER = "USER"


class ProjectStatus(str, Enum):
    ACTIVE = "ACTIVE"
    COMPLETED = "COMPLETED"
    ON_HOLD = "ON_HOLD"


class TaskStatus(str, Enum):
    TODO = "TODO"
    IN_PROGRESS = "IN_PROGRESS"
    DONE = "DONE"


class NotificationType(str, Enum):
    TASK_ASSIGNED = "TASK_ASSIGNED"
    TASK_DUE_SOON = "TASK_DUE_SOON"
    TASK_OVERDUE = "TASK_OVERDUE"
    COMMENT_ADDED = "COMMENT_ADDED"


class UserOut(BaseModel):
    id: int
    email: str
    full_name: str
    role: Role
    team_id: int | None

    class Config:
        from_attributes = True


class UserCreate(BaseModel):
    email: str
    password: str
    full_name: str
    role: Role
    team_id: int | None = None


class UserUpdate(BaseModel):
    full_name: str | None = None
    role: Role | None = None
    team_id: int | None = None


class TeamOut(BaseModel):
    id: int
    name: str
    lead_id: int | None

    class Config:
        from_attributes = True


class TeamCreate(BaseModel):
    name: str
    lead_id: int | None = None


class TeamUpdate(BaseModel):
    name: str | None = None
    lead_id: int | None = None


class ProjectOut(BaseModel):
    id: int
    name: str
    description: str | None
    owner_id: int
    team_id: int | None
    start_date: date | None
    due_date: date | None
    status: ProjectStatus

    class Config:
        from_attributes = True


class ProjectCreate(BaseModel):
    name: str
    description: str | None = None
    team_id: int | None = None
    start_date: date | None = None
    due_date: date | None = None


class ProjectUpdate(BaseModel):
    name: str | None = None
    description: str | None = None
    status: ProjectStatus | None = None
    due_date: date | None = None


class TaskOut(BaseModel):
    id: int
    project_id: int
    title: str
    description: str | None
    assignee_id: int
    status: TaskStatus
    due_date: date | None
    created_by: int

    class Config:
        from_attributes = True


class TaskCreate(BaseModel):
    project_id: int
    title: str
    description: str | None = None
    assignee_id: int
    due_date: date


class TaskUpdate(BaseModel):
    status: TaskStatus | None = None
    assignee_id: int | None = None
    due_date: date | None = None
    title: str | None = None
    description: str | None = None


class TaskStatusUpdate(BaseModel):
    status: TaskStatus


class CommentOut(BaseModel):
    id: int
    task_id: int
    author_id: int
    body: str
    created_at: datetime

    class Config:
        from_attributes = True


class CommentCreate(BaseModel):
    body: str


class NotificationOut(BaseModel):
    id: int
    user_id: int
    type: NotificationType
    payload: str
    read_at: datetime | None
    created_at: datetime

    class Config:
        from_attributes = True


class NotificationRead(BaseModel):
    id: int
    read_at: datetime | None


class LoginRequest(BaseModel):
    email: str
    password: str


class LoginResponse(BaseModel):
    access_token: str
    token_type: str
    user: UserOut


class HierarchyOut(BaseModel):
    team: TeamOut
    lead: UserOut | None
    members: list[UserOut]


class WorkloadItem(BaseModel):
    user: UserOut
    open_tasks: int


class DashboardBase(BaseModel):
    role: Role
    total_tasks: int
    overdue_tasks: int
    due_soon_tasks: int


class DashboardUser(DashboardBase):
    my_tasks: list[TaskOut]


class DashboardLead(DashboardBase):
    team_tasks: list[TaskOut]
    workload: list[WorkloadItem]


class DashboardManager(DashboardBase):
    projects_summary: dict[str, int]
    team_summary: dict[str, int]


class DashboardAdmin(DashboardManager):
    user_count: int
    team_count: int
