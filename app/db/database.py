import os
from sqlalchemy.exc import ArgumentError

from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker, DeclarativeBase

DATABASE_URL = os.getenv("DATABASE_URL", "sqlite:///./arsii.db")
if DATABASE_URL.startswith("postgres://"):
    DATABASE_URL = DATABASE_URL.replace("postgres://", "postgresql://", 1)

engine_kwargs = {
    "echo": False,
}

if DATABASE_URL.startswith("sqlite"):
    engine_kwargs["connect_args"] = {"check_same_thread": False}

try:
    engine = create_engine(DATABASE_URL, **engine_kwargs)
except (ValueError, ArgumentError) as exc:
    raise RuntimeError(
        "Invalid DATABASE_URL configuration. On Render, use the managed "
        "Postgres connection string instead of a placeholder like ':PORT' or "
        "a manually templated value."
    ) from exc

SessionLocal = sessionmaker(bind=engine, autoflush=False, autocommit=False)


class Base(DeclarativeBase):
    pass
