# ARSII-Sfax Project Management MVP

A modern, role‑based project and task management app built for ARSII‑Sfax to unify teams, tasks, and progress tracking.

**Demo video (2 min):** XXXXX

## Quick Start

### Backend
```bash
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
export GEMINI_API_KEY=your_key_here
uvicorn app.main:app --reload
```

### Flutter Client
```bash
cd arsii_mvp
flutter pub get
flutter run
```

### AI
- `GET /ai/insights` returns role-aware AI summaries.
- `GET /ai/workload-conflicts` returns overload and blocker detection.
- If `GEMINI_API_KEY` is missing, the backend falls back to rule-based insights.

## Seeded Accounts
- `admin@arsii.local` / `admin123`
- `manager@arsii.local` / `manager123`
- `lead.a@arsii.local` / `lead123`
- `lead.b@arsii.local` / `lead123`
- `lead.c@arsii.local` / `lead123`
- `lead.d@arsii.local` / `lead123`
- `lead.e@arsii.local` / `lead123`
