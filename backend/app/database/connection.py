import os
from pathlib import Path

from dotenv import load_dotenv
from fastapi import HTTPException
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker, declarative_base

# Resolve backend/.env from this file so the API can be started from the
# repository root or the backend directory.
load_dotenv(Path(__file__).resolve().parents[2] / ".env")

# Get the database URL from .env
DATABASE_URL = os.getenv("DATABASE_URL")

if not DATABASE_URL:
    raise ValueError("DATABASE_URL is not set in the .env file")

try:
    engine = create_engine(DATABASE_URL)
except ImportError:
    engine = None

# Create database session
SessionLocal = sessionmaker(
    autocommit=False,
    autoflush=False,
    bind=engine
)

# Base class for database models
Base = declarative_base()


# Database dependency for FastAPI
def get_db():
    if engine is None:
        raise HTTPException(
            status_code=503,
            detail="PostgreSQL driver is unavailable in the active Python environment",
        )

    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()