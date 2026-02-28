from datetime import date
from sqlalchemy.orm import Session
from app import models
from app.auth import hash_password


def seed_data(db: Session) -> None:
    if db.query(models.User).count() > 0:
        return

    admin = models.User(
        email="admin@arsii.local",
        password_hash=hash_password("admin123"),
        full_name="Admin",
        role=models.Role.ADMIN,
    )
    manager = models.User(
        email="manager@arsii.local",
        password_hash=hash_password("manager123"),
        full_name="Manager",
        role=models.Role.MANAGER,
    )

    team_a = models.Team(name="Engineering Team")
    team_b = models.Team(name="Design Team")
    team_c = models.Team(name="Data & Ops")
    team_d = models.Team(name="Mobile Team")
    team_e = models.Team(name="QA & Support")

    lead_a = models.User(
        email="lead.a@arsii.local",
        password_hash=hash_password("lead123"),
        full_name="Ahmed Ben Salah",
        role=models.Role.LEAD,
        team=team_a,
    )
    lead_b = models.User(
        email="lead.b@arsii.local",
        password_hash=hash_password("lead123"),
        full_name="Salma Trabelsi",
        role=models.Role.LEAD,
        team=team_b,
    )
    lead_c = models.User(
        email="lead.c@arsii.local",
        password_hash=hash_password("lead123"),
        full_name="Youssef Gharbi",
        role=models.Role.LEAD,
        team=team_c,
    )
    lead_d = models.User(
        email="lead.d@arsii.local",
        password_hash=hash_password("lead123"),
        full_name="Amal Maatoug",
        role=models.Role.LEAD,
        team=team_d,
    )
    lead_e = models.User(
        email="lead.e@arsii.local",
        password_hash=hash_password("lead123"),
        full_name="Sami Jaziri",
        role=models.Role.LEAD,
        team=team_e,
    )

    user_a1 = models.User(
        email="user.a1@arsii.local",
        password_hash=hash_password("user123"),
        full_name="Khaled Mansour",
        role=models.Role.USER,
        team=team_a,
    )
    user_a2 = models.User(
        email="user.a2@arsii.local",
        password_hash=hash_password("user123"),
        full_name="Nour Ben Youssef",
        role=models.Role.USER,
        team=team_a,
    )
    user_a3 = models.User(
        email="user.a3@arsii.local",
        password_hash=hash_password("user123"),
        full_name="Lina Harbi",
        role=models.Role.USER,
        team=team_a,
    )
    user_b1 = models.User(
        email="user.b1@arsii.local",
        password_hash=hash_password("user123"),
        full_name="Fatma Zohra",
        role=models.Role.USER,
        team=team_b,
    )
    user_b2 = models.User(
        email="user.b2@arsii.local",
        password_hash=hash_password("user123"),
        full_name="Hichem Riahi",
        role=models.Role.USER,
        team=team_b,
    )
    user_b3 = models.User(
        email="user.b3@arsii.local",
        password_hash=hash_password("user123"),
        full_name="Rim Khelifi",
        role=models.Role.USER,
        team=team_b,
    )
    user_c1 = models.User(
        email="user.c1@arsii.local",
        password_hash=hash_password("user123"),
        full_name="Omar Znaidi",
        role=models.Role.USER,
        team=team_c,
    )
    user_c2 = models.User(
        email="user.c2@arsii.local",
        password_hash=hash_password("user123"),
        full_name="Sana Cherif",
        role=models.Role.USER,
        team=team_c,
    )
    user_c3 = models.User(
        email="user.c3@arsii.local",
        password_hash=hash_password("user123"),
        full_name="Mahdi Baccar",
        role=models.Role.USER,
        team=team_c,
    )
    user_d1 = models.User(
        email="user.d1@arsii.local",
        password_hash=hash_password("user123"),
        full_name="Meriem Saidi",
        role=models.Role.USER,
        team=team_d,
    )
    user_d2 = models.User(
        email="user.d2@arsii.local",
        password_hash=hash_password("user123"),
        full_name="Chokri Ghedira",
        role=models.Role.USER,
        team=team_d,
    )
    user_d3 = models.User(
        email="user.d3@arsii.local",
        password_hash=hash_password("user123"),
        full_name="Aya Bensalem",
        role=models.Role.USER,
        team=team_d,
    )
    user_e1 = models.User(
        email="user.e1@arsii.local",
        password_hash=hash_password("user123"),
        full_name="Wassim Hadhri",
        role=models.Role.USER,
        team=team_e,
    )
    user_e2 = models.User(
        email="user.e2@arsii.local",
        password_hash=hash_password("user123"),
        full_name="Dorra Jmal",
        role=models.Role.USER,
        team=team_e,
    )
    user_e3 = models.User(
        email="user.e3@arsii.local",
        password_hash=hash_password("user123"),
        full_name="Hana Ayari",
        role=models.Role.USER,
        team=team_e,
    )
    user_e4 = models.User(
        email="user.e4@arsii.local",
        password_hash=hash_password("user123"),
        full_name="Ibrahim Khemiri",
        role=models.Role.USER,
        team=team_e,
    )

    db.add_all([
        admin,
        manager,
        team_a,
        team_b,
        team_c,
        team_d,
        team_e,
        lead_a,
        lead_b,
        lead_c,
        lead_d,
        lead_e,
        user_a1,
        user_a2,
        user_a3,
        user_b1,
        user_b2,
        user_b3,
        user_c1,
        user_c2,
        user_c3,
        user_d1,
        user_d2,
        user_d3,
        user_e1,
        user_e2,
        user_e3,
        user_e4,
    ])
    db.flush()

    team_a.lead_id = lead_a.id
    team_b.lead_id = lead_b.id
    team_c.lead_id = lead_c.id
    team_d.lead_id = lead_d.id
    team_e.lead_id = lead_e.id

    project_a = models.Project(
        name="Sfax Smart Campus",
        description="Phase 1 rollout and mobile workflows",
        owner_id=manager.id,
        team_id=team_a.id,
        start_date=date.today(),
        due_date=date.today(),
        status=models.ProjectStatus.ACTIVE,
    )
    project_b = models.Project(
        name="Citizen Portal UX",
        description="Design system and onboarding flow",
        owner_id=manager.id,
        team_id=team_b.id,
        start_date=date.today(),
        due_date=date.today(),
        status=models.ProjectStatus.ACTIVE,
    )
    project_c = models.Project(
        name="Ops Analytics",
        description="Weekly reporting and workload insights",
        owner_id=manager.id,
        team_id=team_c.id,
        start_date=date.today(),
        due_date=date.today(),
        status=models.ProjectStatus.ACTIVE,
    )
    project_d = models.Project(
        name="Mobile First Release",
        description="Android build and onboarding",
        owner_id=manager.id,
        team_id=team_d.id,
        start_date=date.today(),
        due_date=date.today(),
        status=models.ProjectStatus.ACTIVE,
    )
    project_e = models.Project(
        name="Quality Gates",
        description="Automated testing and stability",
        owner_id=manager.id,
        team_id=team_e.id,
        start_date=date.today(),
        due_date=date.today(),
        status=models.ProjectStatus.ACTIVE,
    )
    project_f = models.Project(
        name="Client Insights",
        description="Feedback loops and analytics",
        owner_id=manager.id,
        team_id=team_a.id,
        start_date=date.today(),
        due_date=date.today(),
        status=models.ProjectStatus.ACTIVE,
    )
    project_g = models.Project(
        name="Team Collaboration",
        description="Comments and notifications",
        owner_id=manager.id,
        team_id=team_b.id,
        start_date=date.today(),
        due_date=date.today(),
        status=models.ProjectStatus.ACTIVE,
    )

    db.add_all([project_a, project_b, project_c, project_d, project_e, project_f, project_g])
    db.flush()

    tasks = [
        models.Task(
            project_id=project_a.id,
            title="API Contract Review",
            description="Align endpoints with mobile flows",
            assignee_id=user_a1.id,
            status=models.TaskStatus.IN_PROGRESS,
            due_date=date.today(),
            created_by=lead_a.id,
        ),
        models.Task(
            project_id=project_a.id,
            title="Realtime Updates",
            description="WebSocket integration",
            assignee_id=user_a2.id,
            status=models.TaskStatus.TODO,
            due_date=date.today(),
            created_by=lead_a.id,
        ),
        models.Task(
            project_id=project_a.id,
            title="Task Lifecycle QA",
            description="Verify status changes and notifications",
            assignee_id=user_a3.id,
            status=models.TaskStatus.TODO,
            due_date=date.today(),
            created_by=lead_a.id,
        ),
        models.Task(
            project_id=project_b.id,
            title="Design Tokens",
            description="Colors, typography, spacing",
            assignee_id=user_b1.id,
            status=models.TaskStatus.IN_PROGRESS,
            due_date=date.today(),
            created_by=lead_b.id,
        ),
        models.Task(
            project_id=project_b.id,
            title="Login UX",
            description="Polish login screen and states",
            assignee_id=user_b2.id,
            status=models.TaskStatus.DONE,
            due_date=date.today(),
            created_by=lead_b.id,
        ),
        models.Task(
            project_id=project_b.id,
            title="Dashboard Cards",
            description="Stats and team management views",
            assignee_id=user_b3.id,
            status=models.TaskStatus.TODO,
            due_date=date.today(),
            created_by=lead_b.id,
        ),
        models.Task(
            project_id=project_c.id,
            title="Weekly Report Automation",
            description="Generate weekly summaries",
            assignee_id=user_c1.id,
            status=models.TaskStatus.TODO,
            due_date=date.today(),
            created_by=lead_c.id,
        ),
        models.Task(
            project_id=project_c.id,
            title="Workload Alerts",
            description="Detect overload per user",
            assignee_id=user_c2.id,
            status=models.TaskStatus.IN_PROGRESS,
            due_date=date.today(),
            created_by=lead_c.id,
        ),
        models.Task(
            project_id=project_c.id,
            title="Data Cleanup",
            description="Normalize task metadata",
            assignee_id=user_c3.id,
            status=models.TaskStatus.DONE,
            due_date=date.today(),
            created_by=lead_c.id,
        ),
        models.Task(
            project_id=project_d.id,
            title="Android Build",
            description="Fix build and dependencies",
            assignee_id=user_d1.id,
            status=models.TaskStatus.IN_PROGRESS,
            due_date=date.today(),
            created_by=lead_d.id,
        ),
        models.Task(
            project_id=project_d.id,
            title="Login Flow",
            description="Refine auth and storage",
            assignee_id=user_d2.id,
            status=models.TaskStatus.TODO,
            due_date=date.today(),
            created_by=lead_d.id,
        ),
        models.Task(
            project_id=project_d.id,
            title="Dashboard Polish",
            description="Stat cards and teams",
            assignee_id=user_d3.id,
            status=models.TaskStatus.TODO,
            due_date=date.today(),
            created_by=lead_d.id,
        ),
        models.Task(
            project_id=project_e.id,
            title="Regression Suite",
            description="Smoke tests for core flows",
            assignee_id=user_e1.id,
            status=models.TaskStatus.IN_PROGRESS,
            due_date=date.today(),
            created_by=lead_e.id,
        ),
        models.Task(
            project_id=project_e.id,
            title="Bug Triage",
            description="Organize backlog and priorities",
            assignee_id=user_e2.id,
            status=models.TaskStatus.TODO,
            due_date=date.today(),
            created_by=lead_e.id,
        ),
        models.Task(
            project_id=project_f.id,
            title="Feedback Survey",
            description="In-app survey prompts",
            assignee_id=user_a1.id,
            status=models.TaskStatus.TODO,
            due_date=date.today(),
            created_by=lead_a.id,
        ),
        models.Task(
            project_id=project_g.id,
            title="Comment Threads",
            description="Threaded comments MVP",
            assignee_id=user_b2.id,
            status=models.TaskStatus.TODO,
            due_date=date.today(),
            created_by=lead_b.id,
        ),
    ]
    db.add_all(tasks)
    db.flush()
    comments = [
        models.Comment(task_id=tasks[0].id, author_id=lead_a.id, body="ركز على الاستقرار أولاً"),
        models.Comment(task_id=tasks[3].id, author_id=lead_b.id, body="أحتاج نسخة أولية اليوم"),
        models.Comment(task_id=tasks[6].id, author_id=lead_c.id, body="سأراجع النتائج مع الفريق"),
    ]
    db.add_all(comments)

    notifications = [
        models.Notification(
            user_id=user_a1.id,
            type=models.NotificationType.COMMENT_ADDED,
            payload='{\"task_id\": %d}' % tasks[0].id,
        ),
        models.Notification(
            user_id=user_b1.id,
            type=models.NotificationType.TASK_ASSIGNED,
            payload='{\"task_id\": %d}' % tasks[3].id,
        ),
        models.Notification(
            user_id=user_c2.id,
            type=models.NotificationType.TASK_DUE_SOON,
            payload='{\"task_id\": %d}' % tasks[7].id,
        ),
    ]
    db.add_all(notifications)

    db.commit()
