import asyncio
from datetime import date, datetime, timedelta
from fastapi import FastAPI, WebSocket, WebSocketDisconnect, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from app.db.database import Base, engine, SessionLocal
from app import models
from app.auth import get_current_user
from app.core.ws import WebSocketManager
from app.core.seed import seed_data
from app.routers import auth, users, teams, projects, tasks, comments, notifications, dashboard, workload

app = FastAPI(title="ARSII-Sfax MVP")
app.state.ws_manager = WebSocketManager()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.on_event("startup")
def on_startup() -> None:
    Base.metadata.create_all(bind=engine)
    db = SessionLocal()
    try:
        seed_data(db)
    finally:
        db.close()
    asyncio.create_task(due_soon_notifier())


async def due_soon_notifier() -> None:
    while True:
        await asyncio.sleep(60 * 60)
        db = SessionLocal()
        try:
            today = date.today()
            soon = today + timedelta(days=1)
            tasks_due = (
                db.query(models.Task)
                .filter(
                    models.Task.due_date <= soon,
                    models.Task.due_date >= today,
                    models.Task.status != models.TaskStatus.DONE,
                )
                .all()
            )
            for task in tasks_due:
                exists = (
                    db.query(models.Notification)
                    .filter(
                        models.Notification.user_id == task.assignee_id,
                        models.Notification.type == models.NotificationType.TASK_DUE_SOON,
                        models.Notification.payload.like(f'%"task_id": {task.id}%'),
                        models.Notification.created_at >= datetime.utcnow() - timedelta(hours=24),
                    )
                    .first()
                )
                if exists:
                    continue
                db.add(
                    models.Notification(
                        user_id=task.assignee_id,
                        type=models.NotificationType.TASK_DUE_SOON,
                        payload=f'{{"task_id": {task.id}}}',
                        created_at=datetime.utcnow(),
                    )
                )
            db.commit()
        finally:
            db.close()


@app.websocket("/ws/updates")
async def ws_updates(websocket: WebSocket):
    token = websocket.query_params.get("token")
    if not token:
        await websocket.close(code=1008)
        return
    try:
        user = await _get_user_from_token(token)
    except HTTPException:
        await websocket.close(code=1008)
        return
    await app.state.ws_manager.connect(user.id, websocket)
    try:
        while True:
            await websocket.receive_text()
    except WebSocketDisconnect:
        app.state.ws_manager.disconnect(user.id, websocket)


async def _get_user_from_token(token: str) -> models.User:
    db = SessionLocal()
    try:
        user = get_current_user(token=token, db=db)
        return user
    finally:
        db.close()


app.include_router(auth.router)
app.include_router(users.router)
app.include_router(teams.router)
app.include_router(projects.router)
app.include_router(tasks.router)
app.include_router(comments.router)
app.include_router(notifications.router)
app.include_router(dashboard.router)
app.include_router(workload.router)
