from __future__ import annotations

import os
from dataclasses import dataclass
from pathlib import Path

import google.generativeai as genai


ENV_PATH = Path(__file__).with_name(".env")


def _load_local_env() -> None:
    if not ENV_PATH.exists():
        return
    for line in ENV_PATH.read_text(encoding="utf-8").splitlines():
        stripped = line.strip()
        if not stripped or stripped.startswith("#") or "=" not in stripped:
            continue
        key, value = stripped.split("=", 1)
        os.environ.setdefault(key.strip(), value.strip())


_load_local_env()


@dataclass
class Message:
    role: str
    content: str


class GeminiProvider:
    """Thin Gemini wrapper for grounded MVP summaries."""

    def __init__(self, api_key: str, model: str = "gemini-2.5-flash", name: str = "gemini") -> None:
        self.model = model
        self.name = name
        genai.configure(api_key=api_key)

    def format_messages(self, messages: list[Message]) -> str:
        return "\n\n".join(f"{message.role.upper()}: {message.content}" for message in messages)

    def chat(self, messages: list[Message]) -> str:
        prompt = self.format_messages(messages)
        model = genai.GenerativeModel(self.model)
        response = model.generate_content(prompt)
        if not getattr(response, "text", None):
            raise RuntimeError("Gemini response did not include text")
        return response.text.strip()


def gemini_configured() -> bool:
    return bool(os.getenv("GEMINI_API_KEY"))


def generate_grounded_summary(scope: str, context: dict, insights: list[dict], conflicts: list[dict]) -> str | None:
    api_key = os.getenv("GEMINI_API_KEY")
    if not api_key:
        return None

    model_name = os.getenv("GEMINI_MODEL", "gemini-2.5-flash")
    provider = GeminiProvider(api_key=api_key, model=model_name)
    messages = [
        Message(
            role="system",
            content=(
                "You are an operations copilot for ARSII-Sfax. "
                "Write a short executive summary in 2 or 3 sentences. "
                "Stay grounded in the supplied JSON only. Do not invent facts."
            ),
        ),
        Message(
            role="user",
            content=(
                f"Role scope: {scope}\n"
                f"Task count: {len(context['tasks'])}\n"
                f"Project count: {len(context['projects'])}\n"
                f"Insights: {insights}\n"
                f"Conflicts: {conflicts}"
            ),
        ),
    ]
    try:
        return provider.chat(messages)
    except Exception:
        return None


def generate_chat_reply(scope: str, context: dict, prompt: str, history: list[dict]) -> str | None:
    api_key = os.getenv("GEMINI_API_KEY")
    if not api_key:
        return None

    model_name = os.getenv("GEMINI_MODEL", "gemini-2.5-flash")
    provider = GeminiProvider(api_key=api_key, model=model_name)
    context_snapshot = {
        "scope": scope,
        "project_states": context.get("project_states", {}),
        "projects": context["projects"][:10],
        "tasks": context["tasks"][:20],
        "teams": context.get("teams", [])[:8],
        "member_profiles": context.get("member_profiles", [])[:12],
        "workload": context["workload"][:10],
        "recent_comments": context["recent_comments"][:10],
    }
    messages = [
        Message(
            role="system",
            content=(
                "You are the ARSII-Sfax AI copilot. "
                "Answer only from the provided workspace context. Do not invent facts. "
                "Never say phrases like 'based on the provided context', 'workspace context', or 'I do not have access'. "
                "Be direct, concise, and operational. "
                "If the user greets you or makes small talk, reply naturally in one short sentence and do not dump project metrics unless asked. "
                "If the user asks what you can do, answer with a short capability list and no project metrics. "
                "If the user asks about conflict or risk, answer in this exact structure: "
                "'Conflict status: ... Top issue: ... Action: ...' and add 'Next issue: ...' only if needed. "
                "If the user asks who should handle something, answer in this exact structure: "
                "'Best match: ... Why: ... Availability: ... Fallback: ... Best team: ...'. "
                "When recommending a person or team, use history, specialties, completed work, and availability. "
                "Use real person names from the data. Do not label people as 'User 1', 'User 2', or by internal ids. "
                "Prefer LEAD/USER delivery people over ADMIN/MANAGER unless the request explicitly asks for management oversight. "
                "If the best person is overloaded, choose the next best available fallback. "
                "If you make an inference, label it briefly as 'Inference:'."
            ),
        ),
        Message(
            role="system",
            content=f"Workspace context: {context_snapshot}",
        ),
    ]
    for item in history[-8:]:
        messages.append(Message(role=item.get("role", "user"), content=item.get("content", "")))
    messages.append(Message(role="user", content=prompt))
    try:
        return provider.chat(messages)
    except Exception:
        return None
