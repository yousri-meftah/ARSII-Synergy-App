from datetime import datetime
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from app import models, schemas
from app.auth import get_db, get_current_user
from app.core.ai.context import build_ai_context
from app.core.ai.planning import recommend_team_plan
from app.core.ai.rules import build_chat_fallback_reply, build_conflicts, build_insights, fallback_summary
from app.core.ai.gemini import generate_grounded_summary, gemini_configured, generate_chat_reply

router = APIRouter(prefix="/ai", tags=["ai"])


@router.get(
    "/insights",
    response_model=schemas.AIInsightsResponse,
    summary="AI insights",
    description="Returns role-aware AI insights grounded in current projects, tasks, workload, and comments.",
)
def ai_insights(
    db: Session = Depends(get_db),
    current: models.User = Depends(get_current_user),
):
    context = build_ai_context(db, current)
    conflicts = build_conflicts(context)
    insights = build_insights(context, conflicts)
    summary, source = fallback_summary(current.role.value, insights, conflicts)
    if gemini_configured():
        gemini_summary = generate_grounded_summary(current.role.value, context, insights, conflicts)
        if gemini_summary:
            summary = gemini_summary
            source = "gemini"
    return schemas.AIInsightsResponse(
        summary=summary,
        source=source,
        generated_at=datetime.utcnow(),
        scope=current.role.value,
        insights=[schemas.AIInsightItem(**item) for item in insights],
    )


@router.get(
    "/workload-conflicts",
    response_model=schemas.AIConflictsResponse,
    summary="AI conflict detection",
    description="Returns workload and execution conflicts for the current role scope.",
)
def ai_workload_conflicts(
    db: Session = Depends(get_db),
    current: models.User = Depends(get_current_user),
):
    context = build_ai_context(db, current)
    conflicts = build_conflicts(context)
    insights = build_insights(context, conflicts)
    summary, source = fallback_summary(current.role.value, insights, conflicts)
    if gemini_configured():
        gemini_summary = generate_grounded_summary(current.role.value, context, insights, conflicts)
        if gemini_summary:
            summary = gemini_summary
            source = "gemini"
    return schemas.AIConflictsResponse(
        summary=summary,
        source=source,
        generated_at=datetime.utcnow(),
        scope=current.role.value,
        conflicts=[schemas.AIConflictItem(**item) for item in conflicts],
    )


@router.post(
    "/chat",
    response_model=schemas.AIChatResponse,
    summary="AI chat",
    description="Accepts a user message and optional recent history. Returns a grounded AI reply for the current role scope.",
)
def ai_chat(
    payload: schemas.AIChatRequest,
    db: Session = Depends(get_db),
    current: models.User = Depends(get_current_user),
):
    context = build_ai_context(db, current)
    history = [item.model_dump() for item in payload.history]
    reply = generate_chat_reply(current.role.value, context, payload.message, history)
    source = "gemini" if reply else "rules"
    if not reply:
        reply = build_chat_fallback_reply(payload.message, context)
    return schemas.AIChatResponse(
        reply=reply,
        source=source,
        generated_at=datetime.utcnow(),
        scope=current.role.value,
    )


@router.post(
    "/project-plan",
    response_model=schemas.AIProjectPlanResponse,
    summary="AI project planning",
    description="Accepts a project brief and returns recommended teams, members, and a starter task plan.",
)
def ai_project_plan(
    payload: schemas.AIProjectPlanRequest,
    db: Session = Depends(get_db),
    current: models.User = Depends(get_current_user),
):
    if current.role == models.Role.USER:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Forbidden")
    recommended_teams, tasks, recommended_people, suggested_team_size, suggested_roles = recommend_team_plan(
        db,
        payload.name,
        payload.description,
    )
    summary = (
        f"Built a {suggested_team_size}-person draft squad for {payload.name}, led by {recommended_people[0]['full_name']}."
        if recommended_people
        else f"No strong historical staffing match was found for {payload.name}."
    )
    return schemas.AIProjectPlanResponse(
        summary=summary,
        source="rules",
        generated_at=datetime.utcnow(),
        suggested_team_size=suggested_team_size,
        recommended_people=[schemas.AIRecommendedMember(**item) for item in recommended_people],
        suggested_roles=[schemas.AIRecommendedRoleSlot(**item) for item in suggested_roles],
        recommended_teams=[schemas.AIRecommendedTeam(**item) for item in recommended_teams],
        tasks=[schemas.AIPlannedTask(**item) for item in tasks],
    )
